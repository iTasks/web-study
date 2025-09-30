use std::collections::HashMap;
use std::convert::Infallible;
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};
use std::time::SystemTime;

use bytes::Bytes;
use http_body_util::{combinators::BoxBody, BodyExt, Full};
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{body::Incoming as IncomingBody, Method, Request, Response, StatusCode};
use hyper_util::rt::TokioIo;
use serde::{Deserialize, Serialize};
use tokio::net::TcpListener;

// Data structures for webhook handling
#[derive(Debug, Clone, Serialize, Deserialize)]
struct WebhookEvent {
    id: String,
    event_type: String,
    source: String,
    timestamp: u64,
    payload: serde_json::Value,
}

#[derive(Debug, Clone, Serialize)]
struct WebhookStats {
    total_webhooks: usize,
    events_by_type: HashMap<String, usize>,
    events_by_source: HashMap<String, usize>,
    recent_events: Vec<WebhookEvent>,
}

#[derive(Debug, Serialize)]
struct ApiResponse {
    status: String,
    message: String,
    data: Option<serde_json::Value>,
}

// Shared state for storing webhook events
type SharedState = Arc<Mutex<Vec<WebhookEvent>>>;

/// Main webhook server
#[tokio::main]
pub async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    println!("Starting Rust Webhook Server on http://localhost:8080");
    println!("Available endpoints:");
    println!("  GET  /health          - Health check");
    println!("  GET  /stats           - Webhook statistics");
    println!("  GET  /events          - Recent events");
    println!("  POST /webhook/github  - GitHub webhooks");
    println!("  POST /webhook/slack   - Slack webhooks");
    println!("  POST /webhook/generic - Generic webhooks");
    println!("  POST /webhook/test    - Test endpoint");
    
    let addr: SocketAddr = ([127, 0, 0, 1], 8080).into();
    let listener = TcpListener::bind(addr).await?;
    
    // Shared state for storing webhook events
    let shared_state: SharedState = Arc::new(Mutex::new(Vec::new()));
    
    loop {
        let (stream, _) = listener.accept().await?;
        let io = TokioIo::new(stream);
        let shared_state = Arc::clone(&shared_state);
        
        tokio::task::spawn(async move {
            let service = service_fn(move |req| handle_request(req, Arc::clone(&shared_state)));
            
            if let Err(err) = http1::Builder::new().serve_connection(io, service).await {
                eprintln!("Error serving connection: {:?}", err);
            }
        });
    }
}

/// Handle incoming HTTP requests
async fn handle_request(
    req: Request<IncomingBody>,
    shared_state: SharedState,
) -> Result<Response<BoxBody<Bytes, hyper::Error>>, Infallible> {
    let response = match (req.method(), req.uri().path()) {
        // Health check endpoint
        (&Method::GET, "/health") => handle_health().await,
        
        // Statistics endpoint
        (&Method::GET, "/stats") => handle_stats(shared_state).await,
        
        // Recent events endpoint
        (&Method::GET, "/events") => handle_events(shared_state).await,
        
        // GitHub webhook
        (&Method::POST, "/webhook/github") => handle_github_webhook(req, shared_state).await,
        
        // Slack webhook
        (&Method::POST, "/webhook/slack") => handle_slack_webhook(req, shared_state).await,
        
        // Generic webhook
        (&Method::POST, "/webhook/generic") => handle_generic_webhook(req, shared_state).await,
        
        // Test endpoint
        (&Method::POST, "/webhook/test") => handle_test_webhook(req, shared_state).await,
        
        // 404 for other paths
        _ => handle_not_found().await,
    };
    
    Ok(response)
}

/// Health check endpoint
async fn handle_health() -> Response<BoxBody<Bytes, hyper::Error>> {
    let response = ApiResponse {
        status: "healthy".to_string(),
        message: "Rust Webhook Server is running".to_string(),
        data: Some(serde_json::json!({
            "service": "Rust Webhook Server",
            "version": "1.0.0",
            "timestamp": current_timestamp()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// Statistics endpoint
async fn handle_stats(shared_state: SharedState) -> Response<BoxBody<Bytes, hyper::Error>> {
    let events = shared_state.lock().unwrap();
    
    let mut events_by_type: HashMap<String, usize> = HashMap::new();
    let mut events_by_source: HashMap<String, usize> = HashMap::new();
    
    for event in events.iter() {
        *events_by_type.entry(event.event_type.clone()).or_insert(0) += 1;
        *events_by_source.entry(event.source.clone()).or_insert(0) += 1;
    }
    
    let stats = WebhookStats {
        total_webhooks: events.len(),
        events_by_type,
        events_by_source,
        recent_events: events.iter().rev().take(5).cloned().collect(),
    };
    
    let response = ApiResponse {
        status: "success".to_string(),
        message: "Webhook statistics".to_string(),
        data: Some(serde_json::to_value(&stats).unwrap()),
    };
    
    json_response(StatusCode::OK, &response)
}

/// Recent events endpoint
async fn handle_events(shared_state: SharedState) -> Response<BoxBody<Bytes, hyper::Error>> {
    let events = shared_state.lock().unwrap();
    let recent_events: Vec<_> = events.iter().rev().take(10).cloned().collect();
    
    let response = ApiResponse {
        status: "success".to_string(),
        message: format!("Retrieved {} recent events", recent_events.len()),
        data: Some(serde_json::json!({
            "events": recent_events,
            "total_count": events.len()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// GitHub webhook handler
async fn handle_github_webhook(
    req: Request<IncomingBody>,
    shared_state: SharedState,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    // Extract headers before consuming the request body
    let event_type = req
        .headers()
        .get("X-GitHub-Event")
        .and_then(|h| h.to_str().ok())
        .unwrap_or("unknown")
        .to_string();
    
    let delivery_id = req
        .headers()
        .get("X-GitHub-Delivery")
        .and_then(|h| h.to_str().ok())
        .unwrap_or("unknown")
        .to_string();
    
    // Read body
    let body_bytes = match req.collect().await {
        Ok(collected) => collected.to_bytes(),
        Err(_) => {
            return error_response(StatusCode::BAD_REQUEST, "Failed to read request body");
        }
    };
    
    // Parse JSON payload
    let payload: serde_json::Value = match serde_json::from_slice(&body_bytes) {
        Ok(json) => json,
        Err(_) => {
            return error_response(StatusCode::BAD_REQUEST, "Invalid JSON payload");
        }
    };
    
    // Process GitHub event
    let result = process_github_event(&event_type, &payload);
    
    // Store the webhook event
    let webhook_event = WebhookEvent {
        id: delivery_id.clone(),
        event_type: event_type.clone(),
        source: "github".to_string(),
        timestamp: current_timestamp(),
        payload: payload.clone(),
    };
    
    store_webhook_event(shared_state, webhook_event);
    
    println!("GitHub webhook received: {} ({})", event_type, delivery_id);
    
    let response = ApiResponse {
        status: "processed".to_string(),
        message: result,
        data: Some(serde_json::json!({
            "event_type": event_type,
            "delivery_id": delivery_id,
            "processed_at": current_timestamp()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// Slack webhook handler
async fn handle_slack_webhook(
    req: Request<IncomingBody>,
    shared_state: SharedState,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    // Read body
    let body_bytes = match req.collect().await {
        Ok(collected) => collected.to_bytes(),
        Err(_) => {
            return error_response(StatusCode::BAD_REQUEST, "Failed to read request body");
        }
    };
    
    // Parse JSON payload
    let payload: serde_json::Value = match serde_json::from_slice(&body_bytes) {
        Ok(json) => json,
        Err(_) => {
            return error_response(StatusCode::BAD_REQUEST, "Invalid JSON payload");
        }
    };
    
    // Handle Slack URL verification challenge
    if let Some(challenge) = payload.get("challenge") {
        return json_response(
            StatusCode::OK,
            &serde_json::json!({ "challenge": challenge }),
        );
    }
    
    // Process Slack event
    let event_type = payload
        .get("event")
        .and_then(|e| e.get("type"))
        .and_then(|t| t.as_str())
        .unwrap_or("unknown");
    
    let result = process_slack_event(event_type, &payload);
    
    // Store the webhook event
    let webhook_event = WebhookEvent {
        id: format!("slack-{}", current_timestamp()),
        event_type: event_type.to_string(),
        source: "slack".to_string(),
        timestamp: current_timestamp(),
        payload: payload.clone(),
    };
    
    store_webhook_event(shared_state, webhook_event);
    
    println!("Slack webhook received: {}", event_type);
    
    let response = ApiResponse {
        status: "processed".to_string(),
        message: result,
        data: Some(serde_json::json!({
            "event_type": event_type,
            "processed_at": current_timestamp()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// Generic webhook handler
async fn handle_generic_webhook(
    req: Request<IncomingBody>,
    shared_state: SharedState,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    // Extract headers before consuming the request body
    let user_agent = req
        .headers()
        .get("User-Agent")
        .and_then(|h| h.to_str().ok())
        .unwrap_or("unknown")
        .to_string();
    
    let content_type = req
        .headers()
        .get("Content-Type")
        .and_then(|h| h.to_str().ok())
        .unwrap_or("unknown")
        .to_string();
    
    // Read body
    let body_bytes = match req.collect().await {
        Ok(collected) => collected.to_bytes(),
        Err(_) => {
            return error_response(StatusCode::BAD_REQUEST, "Failed to read request body");
        }
    };
    
    // Try to parse as JSON, fallback to raw text
    let payload = match serde_json::from_slice::<serde_json::Value>(&body_bytes) {
        Ok(json) => json,
        Err(_) => serde_json::json!({
            "raw_body": String::from_utf8_lossy(&body_bytes),
            "content_type": content_type
        }),
    };
    
    // Store the webhook event
    let webhook_event = WebhookEvent {
        id: format!("generic-{}", current_timestamp()),
        event_type: "generic".to_string(),
        source: "generic".to_string(),
        timestamp: current_timestamp(),
        payload: payload.clone(),
    };
    
    store_webhook_event(shared_state, webhook_event);
    
    println!("Generic webhook received from: {}", user_agent);
    
    let response = ApiResponse {
        status: "processed".to_string(),
        message: "Generic webhook processed successfully".to_string(),
        data: Some(serde_json::json!({
            "user_agent": user_agent,
            "payload_size": body_bytes.len(),
            "processed_at": current_timestamp()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// Test webhook handler
async fn handle_test_webhook(
    req: Request<IncomingBody>,
    shared_state: SharedState,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    // Read body (optional for test)
    let body_bytes = req.collect().await.ok().map(|b| b.to_bytes());
    
    let payload = if let Some(body) = body_bytes {
        match serde_json::from_slice::<serde_json::Value>(&body) {
            Ok(json) => json,
            Err(_) => serde_json::json!({
                "message": "Test webhook",
                "timestamp": current_timestamp()
            }),
        }
    } else {
        serde_json::json!({
            "message": "Test webhook",
            "timestamp": current_timestamp()
        })
    };
    
    // Store the webhook event
    let webhook_event = WebhookEvent {
        id: format!("test-{}", current_timestamp()),
        event_type: "test".to_string(),
        source: "test".to_string(),
        timestamp: current_timestamp(),
        payload: payload.clone(),
    };
    
    store_webhook_event(shared_state, webhook_event);
    
    println!("Test webhook received");
    
    let response = ApiResponse {
        status: "success".to_string(),
        message: "Test webhook processed successfully".to_string(),
        data: Some(serde_json::json!({
            "echo": payload,
            "processed_at": current_timestamp()
        })),
    };
    
    json_response(StatusCode::OK, &response)
}

/// 404 handler
async fn handle_not_found() -> Response<BoxBody<Bytes, hyper::Error>> {
    error_response(StatusCode::NOT_FOUND, "Endpoint not found")
}

/// Process GitHub webhook events
fn process_github_event(event_type: &str, payload: &serde_json::Value) -> String {
    match event_type {
        "push" => {
            let repository = payload
                .get("repository")
                .and_then(|r| r.get("full_name"))
                .and_then(|n| n.as_str())
                .unwrap_or("unknown");
            
            let ref_name = payload
                .get("ref")
                .and_then(|r| r.as_str())
                .unwrap_or("unknown");
            
            let commits = payload
                .get("commits")
                .and_then(|c| c.as_array())
                .map(|c| c.len())
                .unwrap_or(0);
            
            format!("Processed push to {} on {} with {} commits", repository, ref_name, commits)
        }
        "pull_request" => {
            let action = payload
                .get("action")
                .and_then(|a| a.as_str())
                .unwrap_or("unknown");
            
            let pr_number = payload
                .get("pull_request")
                .and_then(|pr| pr.get("number"))
                .and_then(|n| n.as_u64())
                .unwrap_or(0);
            
            format!("Processed pull request {} (action: {})", pr_number, action)
        }
        "issues" => {
            let action = payload
                .get("action")
                .and_then(|a| a.as_str())
                .unwrap_or("unknown");
            
            let issue_number = payload
                .get("issue")
                .and_then(|issue| issue.get("number"))
                .and_then(|n| n.as_u64())
                .unwrap_or(0);
            
            format!("Processed issue {} (action: {})", issue_number, action)
        }
        _ => format!("Processed GitHub {} event", event_type),
    }
}

/// Process Slack webhook events
fn process_slack_event(event_type: &str, payload: &serde_json::Value) -> String {
    match event_type {
        "message" => {
            let channel = payload
                .get("event")
                .and_then(|e| e.get("channel"))
                .and_then(|c| c.as_str())
                .unwrap_or("unknown");
            
            let user = payload
                .get("event")
                .and_then(|e| e.get("user"))
                .and_then(|u| u.as_str())
                .unwrap_or("unknown");
            
            format!("Processed message from {} in channel {}", user, channel)
        }
        "app_mention" => {
            let user = payload
                .get("event")
                .and_then(|e| e.get("user"))
                .and_then(|u| u.as_str())
                .unwrap_or("unknown");
            
            format!("Processed app mention from {}", user)
        }
        _ => format!("Processed Slack {} event", event_type),
    }
}

/// Store webhook event in shared state
fn store_webhook_event(shared_state: SharedState, event: WebhookEvent) {
    let mut events = shared_state.lock().unwrap();
    events.push(event);
    
    // Keep only the last 1000 events to prevent memory issues
    if events.len() > 1000 {
        events.remove(0);
    }
}

/// Create JSON response
fn json_response<T: Serialize>(
    status: StatusCode,
    data: &T,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    let json = serde_json::to_string(data).unwrap_or_else(|_| "{}".to_string());
    
    Response::builder()
        .status(status)
        .header("Content-Type", "application/json")
        .body(full(json))
        .unwrap()
}

/// Create error response
fn error_response(status: StatusCode, message: &str) -> Response<BoxBody<Bytes, hyper::Error>> {
    let response = ApiResponse {
        status: "error".to_string(),
        message: message.to_string(),
        data: None,
    };
    
    json_response(status, &response)
}

/// Helper to create a boxed body from a string
fn full<T: Into<Bytes>>(chunk: T) -> BoxBody<Bytes, hyper::Error> {
    Full::new(chunk.into())
        .map_err(|never| match never {})
        .boxed()
}

/// Get current timestamp
fn current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .unwrap()
        .as_secs()
}