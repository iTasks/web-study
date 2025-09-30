import ballerina/http;
import ballerina/io;

// Configuration for the web service
configurable int port = 8080;

// Define a service bound to port 8080
service /api on new http:Listener(port) {
    
    // Resource function for GET /api/hello
    resource function get hello() returns string {
        return "Hello, World from Ballerina!";
    }
    
    // Resource function for GET /api/user/[id]
    resource function get user/[string id]() returns json {
        return {
            "id": id,
            "name": "John Doe",
            "email": "john.doe@example.com",
            "timestamp": check utcNow()
        };
    }
    
    // Resource function for POST /api/user
    resource function post user(@http:Payload json payload) returns json|error {
        // Validate payload
        if payload.name is () || payload.email is () {
            return error("Name and email are required");
        }
        
        return {
            "id": generateId(),
            "name": payload.name,
            "email": payload.email,
            "status": "created",
            "timestamp": check utcNow()
        };
    }
    
    // Resource function for health check
    resource function get health() returns json {
        return {
            "status": "UP",
            "service": "Ballerina Web Service",
            "timestamp": check utcNow()
        };
    }
}

// Utility function to get current UTC time
function utcNow() returns string|error {
    return "2024-01-01T00:00:00Z"; // Simplified for example
}

// Utility function to generate ID
function generateId() returns string {
    return "user_" + (checkpanic int:random(1000, 9999)).toString();
}

public function main() {
    io:println("Starting Ballerina Web Service on port " + port.toString());
    io:println("Visit: http://localhost:" + port.toString() + "/api/hello");
}