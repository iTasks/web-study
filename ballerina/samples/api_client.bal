import ballerina/http;
import ballerina/io;

// Configuration for API endpoints
configurable string baseUrl = "https://jsonplaceholder.typicode.com";

// HTTP client configuration
http:Client httpClient = check new (baseUrl, {
    timeout: 30.0,
    retryConfig: {
        count: 3,
        interval: 2.0,
        backOffFactor: 2.0
    }
});

// Data types for API responses
type Post record {
    int userId;
    int id;
    string title;
    string body;
};

type User record {
    int id;
    string name;
    string username;
    string email;
    Address address;
    string phone;
    string website;
    Company company;
};

type Address record {
    string street;
    string suite;
    string city;
    string zipcode;
    Geo geo;
};

type Geo record {
    string lat;
    string lng;
};

type Company record {
    string name;
    string catchPhrase;
    string bs;
};

public function main() returns error? {
    io:println("=== Ballerina API Client Demo ===\n");
    
    // Example 1: Get all posts
    check getAllPosts();
    
    // Example 2: Get specific post
    check getPostById(1);
    
    // Example 3: Create new post
    check createPost();
    
    // Example 4: Update post
    check updatePost(1);
    
    // Example 5: Delete post
    check deletePost(1);
    
    // Example 6: Get user information
    check getUserInfo(1);
    
    // Example 7: Concurrent API calls
    check concurrentApiCalls();
    
    // Example 8: Error handling
    check errorHandlingExample();
}

// Get all posts
function getAllPosts() returns error? {
    io:println("1. Getting all posts:");
    
    Post[] posts = check httpClient->get("/posts");
    io:println("Retrieved " + posts.length().toString() + " posts");
    
    // Display first 3 posts
    int count = 0;
    foreach Post post in posts {
        if count < 3 {
            io:println("  Post " + post.id.toString() + ": " + post.title);
            count += 1;
        }
    }
    io:println();
}

// Get specific post by ID
function getPostById(int postId) returns error? {
    io:println("2. Getting post by ID " + postId.toString() + ":");
    
    Post post = check httpClient->get("/posts/" + postId.toString());
    io:println("  Title: " + post.title);
    io:println("  User ID: " + post.userId.toString());
    io:println("  Body: " + post.body.substring(0, 50) + "...\n");
}

// Create a new post
function createPost() returns error? {
    io:println("3. Creating new post:");
    
    Post newPost = {
        userId: 1,
        id: 0, // Will be assigned by server
        title: "My New Post from Ballerina",
        body: "This is a post created using Ballerina HTTP client."
    };
    
    Post createdPost = check httpClient->post("/posts", newPost);
    io:println("  Created post with ID: " + createdPost.id.toString());
    io:println("  Title: " + createdPost.title + "\n");
}

// Update an existing post
function updatePost(int postId) returns error? {
    io:println("4. Updating post " + postId.toString() + ":");
    
    Post updatedPost = {
        userId: 1,
        id: postId,
        title: "Updated Post Title",
        body: "This post has been updated using Ballerina."
    };
    
    Post result = check httpClient->put("/posts/" + postId.toString(), updatedPost);
    io:println("  Updated post: " + result.title + "\n");
}

// Delete a post
function deletePost(int postId) returns error? {
    io:println("5. Deleting post " + postId.toString() + ":");
    
    http:Response response = check httpClient->delete("/posts/" + postId.toString());
    io:println("  Delete response status: " + response.statusCode.toString() + "\n");
}

// Get user information
function getUserInfo(int userId) returns error? {
    io:println("6. Getting user info for user " + userId.toString() + ":");
    
    User user = check httpClient->get("/users/" + userId.toString());
    io:println("  Name: " + user.name);
    io:println("  Email: " + user.email);
    io:println("  Company: " + user.company.name);
    io:println("  City: " + user.address.city + "\n");
}

// Demonstrate concurrent API calls
function concurrentApiCalls() returns error? {
    io:println("7. Making concurrent API calls:");
    
    // Create multiple workers for concurrent API calls
    worker postWorker {
        Post[]|error postsResult = httpClient->get("/posts");
        postsResult -> coordinator;
    }
    
    worker userWorker {
        User[]|error usersResult = httpClient->get("/users");
        usersResult -> coordinator;
    }
    
    worker albumWorker {
        json|error albumsResult = httpClient->get("/albums");
        albumsResult -> coordinator;
    }
    
    // Coordinator to collect results
    worker coordinator {
        Post[]|error posts = <- postWorker;
        User[]|error users = <- userWorker;
        json|error albums = <- albumWorker;
        
        if posts is Post[] {
            io:println("  Retrieved " + posts.length().toString() + " posts");
        }
        
        if users is User[] {
            io:println("  Retrieved " + users.length().toString() + " users");
        }
        
        if albums is json {
            io:println("  Retrieved albums data");
        }
    }
    
    wait {postWorker, userWorker, albumWorker, coordinator};
    io:println();
}

// Demonstrate error handling
function errorHandlingExample() returns error? {
    io:println("8. Error handling examples:");
    
    // Try to get a non-existent post
    Post|error postResult = httpClient->get("/posts/9999");
    if postResult is error {
        io:println("  Error getting post 9999: " + postResult.message());
    } else {
        io:println("  Unexpectedly got post: " + postResult.title);
    }
    
    // Try to access invalid endpoint
    json|error invalidResult = httpClient->get("/invalid-endpoint");
    if invalidResult is error {
        io:println("  Error accessing invalid endpoint: " + invalidResult.message());
    }
    
    // Demonstrate retry mechanism with timeout
    http:Client timeoutClient = check new ("https://httpstat.us", {
        timeout: 1.0, // Very short timeout
        retryConfig: {
            count: 2,
            interval: 1.0
        }
    });
    
    json|error timeoutResult = timeoutClient->get("/200?sleep=2000");
    if timeoutResult is error {
        io:println("  Timeout error (expected): " + timeoutResult.message());
    }
    
    io:println("\nAPI client demo completed!");
}