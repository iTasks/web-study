# Webhook API with Plumber
# Required packages: plumber, jsonlite, httr, digest

library(plumber)
library(jsonlite)
library(httr)
library(digest)

# Global variables for storing webhook data
webhook_logs <- list()
webhook_counter <- 0

#* @apiTitle Webhook Handler API
#* @apiDescription A comprehensive webhook handling API built with R Plumber

#* Health check endpoint
#* @get /health
#* @serializer json
function() {
  list(
    status = "healthy",
    service = "R Plumber Webhook API",
    timestamp = Sys.time(),
    version = "1.0.0"
  )
}

#* Get webhook statistics
#* @get /stats
#* @serializer json
function() {
  list(
    total_webhooks = webhook_counter,
    recent_webhooks = length(webhook_logs),
    last_webhook = if(length(webhook_logs) > 0) webhook_logs[[length(webhook_logs)]]$timestamp else NULL,
    endpoints = list(
      github = "/webhook/github",
      slack = "/webhook/slack",
      generic = "/webhook/generic"
    )
  )
}

#* Get recent webhook logs
#* @get /logs
#* @param limit:int Number of recent logs to return (default: 10)
#* @serializer json
function(limit = 10) {
  limit <- as.numeric(limit)
  if (is.na(limit) || limit <= 0) limit <- 10
  
  if (length(webhook_logs) == 0) {
    return(list(message = "No webhook logs available"))
  }
  
  # Return the most recent logs
  start_idx <- max(1, length(webhook_logs) - limit + 1)
  recent_logs <- webhook_logs[start_idx:length(webhook_logs)]
  
  list(
    total_logs = length(webhook_logs),
    showing = length(recent_logs),
    logs = recent_logs
  )
}

#* GitHub webhook handler
#* @post /webhook/github
#* @param req The request object
#* @serializer json
function(req) {
  # Extract headers
  signature <- req$HTTP_X_HUB_SIGNATURE_256 %||% ""
  event_type <- req$HTTP_X_GITHUB_EVENT %||% "unknown"
  delivery_id <- req$HTTP_X_GITHUB_DELIVERY %||% "unknown"
  
  # Parse body
  body_raw <- rawToChar(req$postBody)
  
  # Verify signature (simplified - in production use proper HMAC verification)
  webhook_secret <- Sys.getenv("GITHUB_WEBHOOK_SECRET", "default-secret")
  expected_signature <- paste0("sha256=", digest(body_raw, algo = "sha256", serialize = FALSE))
  
  if (signature != "" && signature != expected_signature) {
    res$status <- 403
    return(list(error = "Invalid signature"))
  }
  
  # Parse JSON payload
  payload <- tryCatch({
    fromJSON(body_raw, simplifyVector = FALSE)
  }, error = function(e) {
    return(list(error = paste("JSON parse error:", e$message)))
  })
  
  if ("error" %in% names(payload)) {
    res$status <- 400
    return(payload)
  }
  
  # Process different GitHub events
  result <- process_github_event(event_type, payload, delivery_id)
  
  # Log the webhook
  log_webhook("github", event_type, payload, result)
  
  return(result)
}

#* Slack webhook handler
#* @post /webhook/slack
#* @param req The request object
#* @serializer json
function(req) {
  # Parse body
  body_raw <- rawToChar(req$postBody)
  
  payload <- tryCatch({
    fromJSON(body_raw, simplifyVector = FALSE)  
  }, error = function(e) {
    return(list(error = paste("JSON parse error:", e$message)))
  })
  
  if ("error" %in% names(payload)) {
    res$status <- 400
    return(payload)
  }
  
  # Handle Slack URL verification challenge
  if (!is.null(payload$challenge)) {
    return(list(challenge = payload$challenge))
  }
  
  # Process Slack event
  result <- process_slack_event(payload)
  
  # Log the webhook
  log_webhook("slack", payload$event$type %||% "unknown", payload, result)
  
  return(result)
}

#* Generic webhook handler
#* @post /webhook/generic
#* @param req The request object
#* @serializer json
function(req) {
  # Extract headers
  content_type <- req$HTTP_CONTENT_TYPE %||% "application/json"
  user_agent <- req$HTTP_USER_AGENT %||% "unknown"
  
  # Parse body based on content type
  body_raw <- rawToChar(req$postBody)
  
  payload <- if (grepl("application/json", content_type)) {
    tryCatch({
      fromJSON(body_raw, simplifyVector = FALSE)
    }, error = function(e) {
      list(raw_body = body_raw, parse_error = e$message)
    })
  } else {
    list(raw_body = body_raw, content_type = content_type)
  }
  
  # Process generic webhook
  result <- process_generic_webhook(payload, content_type, user_agent)
  
  # Log the webhook
  log_webhook("generic", "webhook", payload, result)
  
  return(result)
}

#* Test webhook endpoint (for testing purposes)
#* @post /webhook/test
#* @param message:str Test message
#* @serializer json
function(message = "Hello from R!") {
  test_payload <- list(
    message = message,
    timestamp = Sys.time(),
    source = "test_endpoint"
  )
  
  result <- list(
    status = "received",
    echo = test_payload,
    processed_at = Sys.time()
  )
  
  # Log the test webhook
  log_webhook("test", "test", test_payload, result)
  
  return(result)
}

# Helper function to process GitHub events
process_github_event <- function(event_type, payload, delivery_id) {
  cat("Processing GitHub event:", event_type, "\n")
  
  result <- switch(event_type,
    "push" = process_push_event(payload),
    "pull_request" = process_pull_request_event(payload),
    "issues" = process_issues_event(payload),
    "release" = process_release_event(payload),
    {
      list(
        status = "received",
        message = paste("Unhandled GitHub event type:", event_type),
        event_type = event_type,
        delivery_id = delivery_id
      )
    }
  )
  
  result$delivery_id <- delivery_id
  result$processed_at <- Sys.time()
  
  return(result)
}

# Helper function to process push events
process_push_event <- function(payload) {
  repository <- payload$repository$full_name %||% "unknown"
  ref <- payload$ref %||% "unknown"
  commits <- length(payload$commits %||% list())
  pusher <- payload$pusher$name %||% "unknown"
  
  cat("Push to", repository, "on", ref, "with", commits, "commits by", pusher, "\n")
  
  list(
    status = "processed",
    event = "push",
    repository = repository,
    ref = ref,
    commits = commits,
    pusher = pusher,
    message = paste("Processed push event for", repository)
  )
}

# Helper function to process pull request events
process_pull_request_event <- function(payload) {
  action <- payload$action %||% "unknown"
  pr_number <- payload$pull_request$number %||% 0
  pr_title <- payload$pull_request$title %||% "unknown"
  repository <- payload$repository$full_name %||% "unknown"
  author <- payload$pull_request$user$login %||% "unknown"
  
  cat("Pull request", action, "in", repository, "- PR #", pr_number, ":", pr_title, "\n")
  
  list(
    status = "processed",
    event = "pull_request",
    action = action,
    repository = repository,
    pr_number = pr_number,
    pr_title = pr_title,
    author = author,
    message = paste("Processed pull request", action, "for PR #", pr_number)
  )
}

# Helper function to process issues events
process_issues_event <- function(payload) {
  action <- payload$action %||% "unknown"
  issue_number <- payload$issue$number %||% 0
  issue_title <- payload$issue$title %||% "unknown"
  repository <- payload$repository$full_name %||% "unknown"
  author <- payload$issue$user$login %||% "unknown"
  
  cat("Issue", action, "in", repository, "- Issue #", issue_number, ":", issue_title, "\n")
  
  list(
    status = "processed",
    event = "issues",
    action = action,
    repository = repository,
    issue_number = issue_number,
    issue_title = issue_title,
    author = author,
    message = paste("Processed issue", action, "for Issue #", issue_number)
  )
}

# Helper function to process release events
process_release_event <- function(payload) {
  action <- payload$action %||% "unknown"
  tag_name <- payload$release$tag_name %||% "unknown"
  release_name <- payload$release$name %||% "unknown"
  repository <- payload$repository$full_name %||% "unknown"
  
  cat("Release", action, "in", repository, "- Tag:", tag_name, "\n")
  
  list(
    status = "processed",
    event = "release",
    action = action,
    repository = repository,
    tag_name = tag_name,
    release_name = release_name,
    message = paste("Processed release", action, "for tag", tag_name)
  )
}

# Helper function to process Slack events
process_slack_event <- function(payload) {
  event_type <- payload$event$type %||% "unknown"
  
  cat("Processing Slack event:", event_type, "\n")
  
  result <- switch(event_type,
    "message" = {
      text <- payload$event$text %||% ""
      channel <- payload$event$channel %||% "unknown"
      user <- payload$event$user %||% "unknown"
      
      cat("Message in channel", channel, "by", user, ":", text, "\n")
      
      list(
        status = "processed",
        event = "message",
        channel = channel,
        user = user,
        text = text,
        message = "Processed Slack message"
      )
    },
    "app_mention" = {
      text <- payload$event$text %||% ""
      channel <- payload$event$channel %||% "unknown"
      user <- payload$event$user %||% "unknown"
      
      cat("App mentioned in channel", channel, "by", user, ":", text, "\n")
      
      list(
        status = "processed",
        event = "app_mention",
        channel = channel,
        user = user,
        text = text,
        message = "Processed app mention"
      )
    },
    {
      list(
        status = "received",
        message = paste("Unhandled Slack event type:", event_type),
        event_type = event_type
      )
    }
  )
  
  result$processed_at <- Sys.time()
  return(result)
}

# Helper function to process generic webhooks
process_generic_webhook <- function(payload, content_type, user_agent) {
  cat("Processing generic webhook from", user_agent, "\n")
  
  # Try to extract useful information
  webhook_info <- list(
    content_type = content_type,
    user_agent = user_agent,
    payload_type = class(payload)[1],
    has_timestamp = !is.null(payload$timestamp),
    has_event_type = !is.null(payload$event_type) || !is.null(payload$type)
  )
  
  list(
    status = "processed",
    message = "Generic webhook processed successfully",
    webhook_info = webhook_info,
    processed_at = Sys.time()
  )
}

# Helper function to log webhooks
log_webhook <- function(source, event_type, payload, result) {
  webhook_counter <<- webhook_counter + 1
  
  log_entry <- list(
    id = webhook_counter,
    source = source,
    event_type = event_type,
    timestamp = Sys.time(),
    payload_size = nchar(toJSON(payload, auto_unbox = TRUE)),
    result_status = result$status %||% "unknown",
    result_message = result$message %||% "No message"
  )
  
  # Keep only last 100 logs to prevent memory issues
  if (length(webhook_logs) >= 100) {
    webhook_logs <<- webhook_logs[2:100]
  }
  
  webhook_logs[[length(webhook_logs) + 1]] <<- log_entry
  
  cat("Logged webhook #", webhook_counter, ":", source, "/", event_type, "\n")
}

# Define a custom operator for null coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

# Print startup message
cat("Starting R Plumber Webhook API...\n")
cat("Available endpoints:\n")
cat("  GET  /health - Health check\n")
cat("  GET  /stats - Webhook statistics\n")
cat("  GET  /logs - Recent webhook logs\n")
cat("  POST /webhook/github - GitHub webhooks\n")
cat("  POST /webhook/slack - Slack webhooks\n")
cat("  POST /webhook/generic - Generic webhooks\n")
cat("  POST /webhook/test - Test endpoint\n")

# Run the API if this script is executed directly
if (!interactive()) {
  # Create plumber router
  pr() %>%
    pr_run(host = "0.0.0.0", port = 8080)
}