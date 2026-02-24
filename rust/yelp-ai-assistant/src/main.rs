use std::collections::HashMap;
use std::convert::Infallible;
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};
use std::time::Instant;

use bytes::Bytes;
use http_body_util::{combinators::BoxBody, BodyExt, Full};
use hyper::header::HeaderValue;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{body::Incoming as IncomingBody, Method, Request, Response, StatusCode};
use hyper_util::rt::TokioIo;
use tokio::net::TcpListener;

mod cache;
mod circuit_breaker;
mod intent;
mod models;
mod orchestration;
mod rag;
mod routing;
mod search;

use cache::QueryCache;
use circuit_breaker::{CircuitBreaker, ConcurrencyLimiter};
use intent::IntentClassifier;
use models::{BusinessData, BusinessHours, Photo, QueryRequest, Review};
use orchestration::AnswerOrchestrator;
use rag::RagService;
use routing::QueryRouter;
use search::{PhotoHybridRetrievalService, ReviewVectorSearchService, StructuredSearchService};

// ---------------------------------------------------------------------------
// Shared application state
// ---------------------------------------------------------------------------

struct AppState {
    structured_search: Arc<Mutex<StructuredSearchService>>,
    review_search: Arc<Mutex<ReviewVectorSearchService>>,
    photo_search: Arc<Mutex<PhotoHybridRetrievalService>>,
    intent_classifier: IntentClassifier,
    query_router: QueryRouter,
    orchestrator: AnswerOrchestrator,
    rag_service: RagService,
    cache: QueryCache,
    cb_structured: CircuitBreaker,
    cb_review: CircuitBreaker,
    cb_photo: CircuitBreaker,
    concurrency_limiter: ConcurrencyLimiter,
}

/// Default business ID used when the request does not specify one.
/// Matches the demo data seeded at startup.
const DEFAULT_BUSINESS_ID: &str = "12345";

type SharedState = Arc<AppState>;

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    println!("Starting Yelp AI Assistant on http://0.0.0.0:8080");
    println!("Endpoints:");
    println!("  POST /assistant/query  - Query the assistant");
    println!("  GET  /health           - Basic health check");
    println!("  GET  /health/detailed  - Detailed health with circuit-breaker state");

    let structured_search = Arc::new(Mutex::new(StructuredSearchService::new()));
    let review_search = Arc::new(Mutex::new(ReviewVectorSearchService::new()));
    let photo_search = Arc::new(Mutex::new(PhotoHybridRetrievalService::new()));

    seed_demo_data(
        Arc::clone(&structured_search),
        Arc::clone(&review_search),
        Arc::clone(&photo_search),
    );

    let state: SharedState = Arc::new(AppState {
        structured_search,
        review_search,
        photo_search,
        intent_classifier: IntentClassifier::new(),
        query_router: QueryRouter::new(),
        orchestrator: AnswerOrchestrator::new(),
        rag_service: RagService::new(),
        cache: QueryCache::new(),
        cb_structured: CircuitBreaker::new("structured"),
        cb_review: CircuitBreaker::new("review"),
        cb_photo: CircuitBreaker::new("photo"),
        concurrency_limiter: ConcurrencyLimiter::new(50),
    });

    let addr: SocketAddr = ([0, 0, 0, 0], 8080).into();
    let listener = TcpListener::bind(addr).await?;
    println!("Listening on {}", addr);

    loop {
        let (stream, _) = listener.accept().await?;
        let io = TokioIo::new(stream);
        let state = Arc::clone(&state);

        tokio::task::spawn(async move {
            let service = service_fn(move |req| handle_request(req, Arc::clone(&state)));
            if let Err(err) = http1::Builder::new().serve_connection(io, service).await {
                eprintln!("Connection error: {:?}", err);
            }
        });
    }
}

// ---------------------------------------------------------------------------
// Request dispatcher
// ---------------------------------------------------------------------------

async fn handle_request(
    req: Request<IncomingBody>,
    state: SharedState,
) -> Result<Response<BoxBody<Bytes, hyper::Error>>, Infallible> {
    // Extract correlation ID before consuming the request
    let correlation_id = req
        .headers()
        .get("x-correlation-id")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("unknown")
        .to_string();

    let mut response = match (req.method(), req.uri().path()) {
        (&Method::GET, "/health") => handle_health().await,
        (&Method::GET, "/health/detailed") => handle_health_detailed(Arc::clone(&state)).await,
        (&Method::POST, "/assistant/query") => handle_query(req, Arc::clone(&state)).await,
        _ => error_response(StatusCode::NOT_FOUND, "Not found"),
    };

    // Echo X-Correlation-ID back to the caller
    if let Ok(val) = HeaderValue::from_str(&correlation_id) {
        response.headers_mut().insert("x-correlation-id", val);
    }

    Ok(response)
}

// ---------------------------------------------------------------------------
// GET /health
// ---------------------------------------------------------------------------

async fn handle_health() -> Response<BoxBody<Bytes, hyper::Error>> {
    json_response(
        StatusCode::OK,
        &serde_json::json!({
            "status": "healthy",
            "service": "yelp-ai-assistant",
            "version": "1.0.0"
        }),
    )
}

// ---------------------------------------------------------------------------
// GET /health/detailed
// ---------------------------------------------------------------------------

async fn handle_health_detailed(state: SharedState) -> Response<BoxBody<Bytes, hyper::Error>> {
    let cb_s = format!("{:?}", state.cb_structured.get_state());
    let cb_r = format!("{:?}", state.cb_review.get_state());
    let cb_p = format!("{:?}", state.cb_photo.get_state());

    json_response(
        StatusCode::OK,
        &serde_json::json!({
            "status": "healthy",
            "services": {
                "structured_search": { "status": "ok", "circuit_breaker": cb_s },
                "review_vector_search": { "status": "ok", "circuit_breaker": cb_r },
                "photo_hybrid_retrieval": { "status": "ok", "circuit_breaker": cb_p }
            },
            "cache": {
                "status": "ok",
                "max_size": 10_000,
                "ttl_seconds": 300
            },
            "concurrency_limiter": {
                "max_concurrent": state.concurrency_limiter.max_concurrent
            }
        }),
    )
}

// ---------------------------------------------------------------------------
// POST /assistant/query
// ---------------------------------------------------------------------------

async fn handle_query(
    req: Request<IncomingBody>,
    state: SharedState,
) -> Response<BoxBody<Bytes, hyper::Error>> {
    let start = Instant::now();

    // Concurrency gate
    let _permit = state.concurrency_limiter.acquire().await;

    // Read and parse body
    let body_bytes = match req.collect().await {
        Ok(c) => c.to_bytes(),
        Err(_) => return error_response(StatusCode::BAD_REQUEST, "Failed to read request body"),
    };

    let query_req: QueryRequest = match serde_json::from_slice(&body_bytes) {
        Ok(r) => r,
        Err(e) => {
            return error_response(
                StatusCode::BAD_REQUEST,
                &format!("Invalid JSON: {}", e),
            )
        }
    };

    let business_id = query_req
        .business_id
        .clone()
        .unwrap_or_else(|| DEFAULT_BUSINESS_ID.to_string());

    // Cache hit?
    if let Some(cached) = state.cache.get(&business_id, &query_req.query) {
        return json_response(StatusCode::OK, &cached);
    }

    // Classify intent
    let (intent, _confidence, _intent_latency) =
        state.intent_classifier.classify(&query_req.query);

    // Routing decision
    let decision = state.query_router.decide(intent.clone());

    // ------------------------------------------------------------------
    // Parallel search: spawn all blocking tasks up-front, then await
    // ------------------------------------------------------------------
    let ss_task = if decision.use_structured {
        let svc = Arc::clone(&state.structured_search);
        let q = query_req.query.clone();
        let bid = business_id.clone();
        let cb = state.cb_structured.clone();
        Some(tokio::task::spawn_blocking(move || {
            cb.call(|| svc.lock().unwrap().search(&q, Some(&bid)))
                .unwrap_or_default()
        }))
    } else {
        None
    };

    let rv_task = if decision.use_review_vector {
        let svc = Arc::clone(&state.review_search);
        let q = query_req.query.clone();
        let bid = business_id.clone();
        let cb = state.cb_review.clone();
        Some(tokio::task::spawn_blocking(move || {
            cb.call(|| svc.lock().unwrap().search(&q, Some(&bid), 5))
                .unwrap_or_default()
        }))
    } else {
        None
    };

    let ph_task = if decision.use_photo_hybrid {
        let svc = Arc::clone(&state.photo_search);
        let q = query_req.query.clone();
        let bid = business_id.clone();
        let cb = state.cb_photo.clone();
        Some(tokio::task::spawn_blocking(move || {
            cb.call(|| svc.lock().unwrap().search(&q, Some(&bid), 5))
                .unwrap_or_default()
        }))
    } else {
        None
    };

    // Await all concurrently
    let (structured_results, review_results, photo_results) = tokio::join!(
        async { if let Some(t) = ss_task { t.await.unwrap_or_default() } else { vec![] } },
        async { if let Some(t) = rv_task { t.await.unwrap_or_default() } else { vec![] } },
        async { if let Some(t) = ph_task { t.await.unwrap_or_default() } else { vec![] } },
    );

    // Orchestrate evidence
    let bundle = state
        .orchestrator
        .orchestrate(structured_results, review_results, photo_results, &decision);

    let latency_ms = start.elapsed().as_secs_f64() * 1000.0;

    // Generate answer
    let response =
        state
            .rag_service
            .generate_answer(&query_req.query, &intent, &bundle, latency_ms);

    // Store in cache
    state.cache.set(&business_id, &query_req.query, response.clone());

    json_response(StatusCode::OK, &response)
}

// ---------------------------------------------------------------------------
// Demo data seed
// ---------------------------------------------------------------------------

fn seed_demo_data(
    structured: Arc<Mutex<StructuredSearchService>>,
    reviews: Arc<Mutex<ReviewVectorSearchService>>,
    photos: Arc<Mutex<PhotoHybridRetrievalService>>,
) {
    let mut amenities = HashMap::new();
    amenities.insert("patio".to_string(), true);
    amenities.insert("parking".to_string(), true);
    amenities.insert("wifi".to_string(), false);
    amenities.insert("heated_seating".to_string(), true);

    let business = BusinessData {
        business_id: "12345".to_string(),
        name: "The Rustic Table".to_string(),
        address: "123 Main St, San Francisco, CA 94102".to_string(),
        phone: "(415) 555-0123".to_string(),
        price_range: "$$".to_string(),
        hours: vec![
            BusinessHours {
                day: "Monday".to_string(),
                open_time: "11:00".to_string(),
                close_time: "22:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Tuesday".to_string(),
                open_time: "11:00".to_string(),
                close_time: "22:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Wednesday".to_string(),
                open_time: "11:00".to_string(),
                close_time: "22:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Thursday".to_string(),
                open_time: "11:00".to_string(),
                close_time: "22:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Friday".to_string(),
                open_time: "11:00".to_string(),
                close_time: "23:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Saturday".to_string(),
                open_time: "10:00".to_string(),
                close_time: "23:00".to_string(),
                is_closed: false,
            },
            BusinessHours {
                day: "Sunday".to_string(),
                open_time: "10:00".to_string(),
                close_time: "21:00".to_string(),
                is_closed: false,
            },
        ],
        amenities,
        categories: vec![
            "American".to_string(),
            "Farm-to-Table".to_string(),
            "Brunch".to_string(),
        ],
        rating: 4.5,
        review_count: 128,
    };

    structured.lock().unwrap().add_business(business);

    let review_data: &[(&str, &str, f64, &str)] = &[
        (
            "rev001", "user001", 5.0,
            "Amazing farm-to-table food! The rustic ambiance is perfect for a date night. The patio is beautiful and heated.",
        ),
        (
            "rev002", "user002", 4.0,
            "Great food and excellent service. The parking is convenient and the menu is creative.",
        ),
        (
            "rev003", "user003", 4.5,
            "Incredible seasonal dishes with local ingredients. Perfect for brunch on weekends. Highly recommend!",
        ),
    ];
    {
        let mut svc = reviews.lock().unwrap();
        for &(rid, uid, rating, text) in review_data {
            svc.add_review(Review {
                review_id: rid.to_string(),
                business_id: "12345".to_string(),
                user_id: uid.to_string(),
                rating,
                text: text.to_string(),
            });
        }
    }

    let photo_data: &[(&str, &str, &str)] = &[
        (
            "photo001",
            "https://example.com/photos/rustic-table-interior.jpg",
            "Cozy interior with wooden beams and warm lighting",
        ),
        (
            "photo002",
            "https://example.com/photos/rustic-table-patio.jpg",
            "Beautiful heated patio with string lights and seasonal flowers",
        ),
    ];
    {
        let mut svc = photos.lock().unwrap();
        for &(pid, url, caption) in photo_data {
            svc.add_photo(Photo {
                photo_id: pid.to_string(),
                business_id: "12345".to_string(),
                url: url.to_string(),
                caption: caption.to_string(),
            });
        }
    }

    println!("Demo data seeded: The Rustic Table (business_id=12345), 3 reviews, 2 photos");
}

// ---------------------------------------------------------------------------
// HTTP helpers
// ---------------------------------------------------------------------------

fn json_response<T: serde::Serialize>(
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

fn error_response(status: StatusCode, message: &str) -> Response<BoxBody<Bytes, hyper::Error>> {
    json_response(
        status,
        &serde_json::json!({ "error": message, "status": status.as_u16() }),
    )
}

fn full<T: Into<Bytes>>(chunk: T) -> BoxBody<Bytes, hyper::Error> {
    Full::new(chunk.into())
        .map_err(|never| match never {})
        .boxed()
}
