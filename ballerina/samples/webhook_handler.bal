import ballerina/http;
import ballerina/io;
import ballerina/crypto;

// Webhook configuration
configurable int webhookPort = 8081;
configurable string webhookSecret = "my-webhook-secret";

// Webhook service to handle incoming webhooks
service /webhook on new http:Listener(webhookPort) {
    
    // GitHub-style webhook handler
    resource function post github(http:Request request) returns http:Response|error {
        // Verify webhook signature
        string? signature = request.getHeader("X-Hub-Signature-256");
        if signature is () {
            return createErrorResponse(401, "Missing signature header");
        }
        
        // Get payload
        json payload = check request.getJsonPayload();
        
        // Verify signature (simplified example)
        if !verifySignature(payload.toString(), signature, webhookSecret) {
            return createErrorResponse(403, "Invalid signature");
        }
        
        // Process webhook event
        string eventType = request.getHeader("X-GitHub-Event") ?: "unknown";
        check processGitHubEvent(eventType, payload);
        
        return createSuccessResponse("Webhook processed successfully");
    }
    
    // Generic webhook handler
    resource function post generic(http:Request request) returns http:Response|error {
        json payload = check request.getJsonPayload();
        
        io:println("Received webhook payload:");
        io:println(payload.toJsonString());
        
        // Process the webhook asynchronously
        worker webhookProcessor {
            error? result = processWebhook(payload);
            if result is error {
                io:println("Error processing webhook: " + result.message());
            }
        }
        
        return createSuccessResponse("Webhook received");
    }
    
    // Slack webhook handler
    resource function post slack(http:Request request) returns http:Response|error {
        json payload = check request.getJsonPayload();
        
        // Handle Slack challenge verification
        if payload.challenge is string {
            return createJsonResponse({"challenge": payload.challenge});
        }
        
        // Process Slack event
        check processSlackEvent(payload);
        
        return createSuccessResponse("Slack event processed");
    }
}

// Function to verify webhook signature
function verifySignature(string payload, string signature, string secret) returns boolean {
    // Simplified signature verification
    // In production, use proper HMAC-SHA256 verification
    string expectedSignature = "sha256=" + crypto:hashSha256(payload.toBytes()).toBase16();
    return signature == expectedSignature;
}

// Function to process GitHub webhook events
function processGitHubEvent(string eventType, json payload) returns error? {
    match eventType {
        "push" => {
            io:println("Processing push event");
            check processPushEvent(payload);
        }
        "pull_request" => {
            io:println("Processing pull request event");
            check processPullRequestEvent(payload);
        }
        "issues" => {
            io:println("Processing issues event");
            check processIssuesEvent(payload);
        }
        _ => {
            io:println("Unknown event type: " + eventType);
        }
    }
}

// Function to process push events
function processPushEvent(json payload) returns error? {
    string repository = payload.repository.full_name.toString();
    string ref = payload.ref.toString();
    int commits = payload.commits.length();
    
    io:println("Push to " + repository + " on " + ref + " with " + commits.toString() + " commits");
}

// Function to process pull request events
function processPullRequestEvent(json payload) returns error? {
    string action = payload.action.toString();
    string prTitle = payload.pull_request.title.toString();
    string repository = payload.repository.full_name.toString();
    
    io:println("Pull request " + action + " in " + repository + ": " + prTitle);
}

// Function to process issues events
function processIssuesEvent(json payload) returns error? {
    string action = payload.action.toString();
    string issueTitle = payload.issue.title.toString();
    string repository = payload.repository.full_name.toString();
    
    io:println("Issue " + action + " in " + repository + ": " + issueTitle);
}

// Function to process Slack events
function processSlackEvent(json payload) returns error? {
    string eventType = payload.event.'type.toString();
    
    match eventType {
        "message" => {
            string text = payload.event.text.toString();
            string channel = payload.event.channel.toString();
            io:println("Message in channel " + channel + ": " + text);
        }
        "app_mention" => {
            string text = payload.event.text.toString();
            string user = payload.event.user.toString();
            io:println("App mentioned by " + user + ": " + text);
        }
        _ => {
            io:println("Unknown Slack event type: " + eventType);
        }
    }
}

// Generic webhook processor
function processWebhook(json payload) returns error? {
    // Simulate processing time
    runtime:sleep(1.0);
    
    io:println("Webhook processed at: " + check utcNow());
    
    // Here you could:
    // - Save to database
    // - Send notifications
    // - Trigger other processes
    // - Call external APIs
}

// Helper functions for HTTP responses
function createSuccessResponse(string message) returns http:Response {
    http:Response response = new;
    response.statusCode = 200;
    response.setJsonPayload({"status": "success", "message": message});
    return response;
}

function createErrorResponse(int statusCode, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = statusCode;
    response.setJsonPayload({"status": "error", "message": message});
    return response;
}

function createJsonResponse(json payload) returns http:Response {
    http:Response response = new;
    response.statusCode = 200;
    response.setJsonPayload(payload);
    return response;
}

function utcNow() returns string|error {
    return "2024-01-01T00:00:00Z"; // Simplified for example
}

public function main() {
    io:println("Starting Webhook Handler on port " + webhookPort.toString());
    io:println("Endpoints:");
    io:println("  POST http://localhost:" + webhookPort.toString() + "/webhook/github");
    io:println("  POST http://localhost:" + webhookPort.toString() + "/webhook/generic");
    io:println("  POST http://localhost:" + webhookPort.toString() + "/webhook/slack");
}