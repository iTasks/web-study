# HTTP Client Examples in R
# Required packages: httr, jsonlite, curl

library(httr)
library(jsonlite)

# Check for optional packages
has_curl <- requireNamespace("curl", quietly = TRUE)
if (has_curl) library(curl)

cat("=== R HTTP Client Demo ===\n\n")

# Configuration
base_url <- "https://jsonplaceholder.typicode.com"
timeout_seconds <- 30

# Example 1: Basic GET requests
basic_get_examples <- function() {
  cat("1. Basic GET Requests:\n")
  
  # Simple GET request
  cat("  Fetching posts...\n")
  response <- GET(paste0(base_url, "/posts"), timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    posts <- content(response, "parsed")
    cat("    Retrieved", length(posts), "posts\n")
    
    # Display first post
    if (length(posts) > 0) {
      first_post <- posts[[1]]
      cat("    First post: '", substr(first_post$title, 1, 50), "...'\n", sep = "")
    }
  } else {
    cat("    Error:", status_code(response), "\n")
  }
  
  # GET with query parameters
  cat("  Fetching posts for user 1...\n")
  response <- GET(paste0(base_url, "/posts"), 
                  query = list(userId = 1),
                  timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    user_posts <- content(response, "parsed")
    cat("    User 1 has", length(user_posts), "posts\n")
  }
  
  # GET specific resource
  cat("  Fetching specific post (ID: 1)...\n")
  response <- GET(paste0(base_url, "/posts/1"), timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    post <- content(response, "parsed")
    cat("    Post title:", post$title, "\n")
    cat("    Post body length:", nchar(post$body), "characters\n")
  }
  
  cat("\n")
}

# Example 2: POST requests with data
post_examples <- function() {
  cat("2. POST Requests:\n")
  
  # Create new post
  new_post <- list(
    title = "My New Post from R",
    body = "This is a post created using R's httr package.",
    userId = 1
  )
  
  cat("  Creating new post...\n")
  response <- POST(paste0(base_url, "/posts"),
                   body = new_post,
                   encode = "json",
                   timeout(timeout_seconds))
  
  if (status_code(response) == 201) {
    created_post <- content(response, "parsed")
    cat("    Created post with ID:", created_post$id, "\n")
    cat("    Title:", created_post$title, "\n")
  } else {
    cat("    Error creating post:", status_code(response), "\n")
  }
  
  # POST with form data
  form_data <- list(
    name = "John Doe",
    email = "john.doe@example.com",
    message = "Hello from R!"
  )
  
  cat("  Sending form data...\n")
  # Note: This endpoint doesn't exist, so we'll simulate the response
  tryCatch({
    response <- POST("https://httpbin.org/post",
                     body = form_data,
                     encode = "form",
                     timeout(timeout_seconds))
    
    if (status_code(response) == 200) {
      result <- content(response, "parsed")
      cat("    Form submitted successfully\n")
      cat("    Echo data keys:", paste(names(result$form), collapse = ", "), "\n")
    }
  }, error = function(e) {
    cat("    Form submission demo (endpoint may not be available)\n")
  })
  
  cat("\n")
}

# Example 3: PUT and PATCH requests
put_patch_examples <- function() {
  cat("3. PUT and PATCH Requests:\n")
  
  # Update post with PUT (complete replacement)
  updated_post <- list(
    id = 1,
    title = "Updated Post Title",
    body = "This post has been completely updated using R.",
    userId = 1
  )
  
  cat("  Updating post with PUT...\n")
  response <- PUT(paste0(base_url, "/posts/1"),
                  body = updated_post,
                  encode = "json",
                  timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    result <- content(response, "parsed")
    cat("    PUT successful - Updated title:", result$title, "\n")
  } else {
    cat("    PUT failed:", status_code(response), "\n")
  }
  
  # Partial update with PATCH
  patch_data <- list(title = "Partially Updated Title")
  
  cat("  Updating post with PATCH...\n")
  response <- PATCH(paste0(base_url, "/posts/1"),
                    body = patch_data,
                    encode = "json",
                    timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    result <- content(response, "parsed")
    cat("    PATCH successful - New title:", result$title, "\n")
  } else {
    cat("    PATCH failed:", status_code(response), "\n")
  }
  
  cat("\n")
}

# Example 4: DELETE requests
delete_examples <- function() {
  cat("4. DELETE Requests:\n")
  
  cat("  Deleting post 1...\n")
  response <- DELETE(paste0(base_url, "/posts/1"), timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    cat("    Post deleted successfully\n")
  } else {
    cat("    Delete failed:", status_code(response), "\n")
  }
  
  cat("\n")
}

# Example 5: Headers and authentication
headers_auth_examples <- function() {
  cat("5. Headers and Authentication:\n")
  
  # Custom headers
  custom_headers <- add_headers(
    "User-Agent" = "R-HTTP-Client/1.0",
    "Accept" = "application/json",
    "X-Custom-Header" = "MyValue"
  )
  
  cat("  Request with custom headers...\n")
  response <- GET(paste0(base_url, "/posts/1"),
                  custom_headers,
                  timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    cat("    Request successful with custom headers\n")
  }
  
  # Basic authentication (simulated)
  cat("  Basic authentication example...\n")
  tryCatch({
    response <- GET("https://httpbin.org/basic-auth/user/pass",
                    authenticate("user", "pass"),
                    timeout(timeout_seconds))
    
    if (status_code(response) == 200) {
      cat("    Basic auth successful\n")
    }
  }, error = function(e) {
    cat("    Basic auth demo (endpoint may not be available)\n")
  })
  
  # API key authentication (simulated)
  cat("  API key authentication...\n")
  api_key_headers <- add_headers("Authorization" = "Bearer YOUR_API_KEY_HERE")
  
  # This would be used in a real scenario:
  # response <- GET("https://api.example.com/data", api_key_headers)
  cat("    API key headers configured (demo only)\n")
  
  cat("\n")
}

# Example 6: Error handling and retries
error_handling_examples <- function() {
  cat("6. Error Handling and Retries:\n")
  
  # Handle HTTP errors
  cat("  Testing error handling...\n")
  
  # Try to access non-existent resource
  response <- GET(paste0(base_url, "/posts/99999"), timeout(timeout_seconds))
  
  if (status_code(response) == 404) {
    cat("    Handled 404 error correctly\n")
  }
  
  # Comprehensive error handling function
  safe_http_get <- function(url, max_retries = 3) {
    for (attempt in 1:max_retries) {
      tryCatch({
        response <- GET(url, timeout(timeout_seconds))
        
        if (status_code(response) >= 200 && status_code(response) < 300) {
          return(list(success = TRUE, data = content(response, "parsed")))
        } else if (status_code(response) >= 400 && status_code(response) < 500) {
          # Client error - don't retry
          return(list(success = FALSE, error = paste("Client error:", status_code(response))))
        } else {
          # Server error - might retry
          if (attempt == max_retries) {
            return(list(success = FALSE, error = paste("Server error:", status_code(response))))
          }
          cat("    Attempt", attempt, "failed, retrying...\n")
          Sys.sleep(1)  # Wait before retry
        }
      }, error = function(e) {
        if (attempt == max_retries) {
          return(list(success = FALSE, error = paste("Network error:", e$message)))
        }
        cat("    Network error on attempt", attempt, ", retrying...\n")
        Sys.sleep(1)
      })
    }
  }
  
  # Test the robust function
  cat("  Testing robust HTTP function...\n")
  result <- safe_http_get(paste0(base_url, "/posts/1"))
  
  if (result$success) {
    cat("    Robust function succeeded\n")
  } else {
    cat("    Robust function failed:", result$error, "\n")
  }
  
  cat("\n")
}

# Example 7: Concurrent requests
concurrent_requests_example <- function() {
  cat("7. Concurrent HTTP Requests:\n")
  
  # Function to fetch a post
  fetch_post <- function(post_id) {
    response <- GET(paste0(base_url, "/posts/", post_id), timeout(timeout_seconds))
    if (status_code(response) == 200) {
      post <- content(response, "parsed")
      return(list(id = post_id, title = post$title, success = TRUE))
    } else {
      return(list(id = post_id, error = status_code(response), success = FALSE))
    }
  }
  
  # Sequential requests
  cat("  Making sequential requests...\n")
  post_ids <- 1:5
  
  start_time <- Sys.time()
  sequential_results <- lapply(post_ids, fetch_post)
  sequential_time <- as.numeric(Sys.time() - start_time)
  
  # Simulate concurrent requests (R doesn't have built-in async HTTP, but we can demonstrate the concept)
  cat("  Simulating concurrent requests concept...\n")
  
  successful_posts <- sum(sapply(sequential_results, function(x) x$success))
  cat("    Retrieved", successful_posts, "posts successfully\n")
  cat("    Sequential time:", round(sequential_time, 2), "seconds\n")
  
  # In a real application, you might use future package for true concurrency:
  # library(future)
  # plan(multisession)
  # concurrent_results <- future_lapply(post_ids, fetch_post)
  
  cat("\n")
}

# Example 8: Working with different content types
content_types_example <- function() {
  cat("8. Different Content Types:\n")
  
  # JSON content (default)
  cat("  Working with JSON...\n")
  response <- GET(paste0(base_url, "/posts/1"), timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    # Parse as JSON
    json_data <- content(response, "parsed")
    cat("    JSON title:", json_data$title, "\n")
    
    # Raw JSON text
    json_text <- content(response, "text")
    cat("    JSON text length:", nchar(json_text), "characters\n")
  }
  
  # XML content (simulated)
  cat("  XML content handling...\n")
  tryCatch({
    # This would be for XML APIs
    xml_headers <- add_headers("Accept" = "application/xml")
    # response <- GET("https://api.example.com/data.xml", xml_headers)
    cat("    XML headers configured (demo only)\n")
  }, error = function(e) {
    cat("    XML demo (no XML endpoint available)\n")
  })
  
  # Binary content (images, files)
  cat("  Binary content handling...\n")
  tryCatch({
    # Example: Download an image
    img_response <- GET("https://httpbin.org/image/png", timeout(timeout_seconds))
    if (status_code(img_response) == 200) {
      binary_data <- content(img_response, "raw")
      cat("    Downloaded binary data:", length(binary_data), "bytes\n")
    }
  }, error = function(e) {
    cat("    Binary content demo (endpoint may not be available)\n")
  })
  
  cat("\n")
}

# Example 9: Response analysis
response_analysis_example <- function() {
  cat("9. Response Analysis:\n")
  
  response <- GET(paste0(base_url, "/posts"), timeout(timeout_seconds))
  
  if (status_code(response) == 200) {
    # Response headers
    cat("  Response Headers:\n")
    response_headers <- headers(response)
    important_headers <- c("content-type", "content-length", "server", "date")
    
    for (header in important_headers) {
      if (header %in% names(response_headers)) {
        cat("    ", header, ":", response_headers[[header]], "\n")
      }
    }
    
    # Response timing
    cat("  Response Details:\n")
    cat("    Status Code:", status_code(response), "\n")
    cat("    Status Message:", http_status(response)$message, "\n")
    
    # Content analysis
    content_data <- content(response, "parsed")
    cat("    Content Type: JSON Array\n")
    cat("    Array Length:", length(content_data), "\n")
    
    if (length(content_data) > 0) {
      first_item <- content_data[[1]]
      cat("    First Item Keys:", paste(names(first_item), collapse = ", "), "\n")
    }
  }
  
  cat("\n")
}

# Main function to run all examples
main <- function() {
  cat("Starting HTTP client demonstrations...\n\n")
  
  basic_get_examples()
  post_examples()
  put_patch_examples()
  delete_examples()
  headers_auth_examples()
  error_handling_examples()
  concurrent_requests_example()
  content_types_example()
  response_analysis_example()
  
  cat("HTTP client demo completed!\n")
  cat("\nKey takeaways:\n")
  cat("• httr package provides comprehensive HTTP client functionality\n")
  cat("• Always handle errors and implement proper retry logic\n")
  cat("• Use appropriate timeouts for production applications\n")
  cat("• Consider security when handling authentication\n")
  cat("• Parse response content according to the expected format\n")
}

# Execute main function if script is run directly
if (!interactive()) {
  main()
} else {
  cat("Run main() to execute all HTTP client examples\n")
}