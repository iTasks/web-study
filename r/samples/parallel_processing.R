# Parallel Processing and Threading in R
# Required packages: parallel, future, future.apply, doParallel, foreach

library(parallel)
library(future)
library(future.apply)

# Check if optional packages are available
has_doParallel <- requireNamespace("doParallel", quietly = TRUE)
has_foreach <- requireNamespace("foreach", quietly = TRUE)

if (has_doParallel && has_foreach) {
  library(doParallel)
  library(foreach)
}

cat("=== R Parallel Processing Demo ===\n\n")

# Set up parallel backend using future
plan(multisession, workers = detectCores() - 1)

cat("Available CPU cores:", detectCores(), "\n")
cat("Using cores for parallel processing:", availableCores(), "\n\n")

# Example 1: Basic parallel processing with parallel package
parallel_basic_example <- function() {
  cat("1. Basic Parallel Processing with parallel package:\n")
  
  # Create some sample data
  data_list <- list(
    runif(1000000, 0, 100),
    runif(1000000, 0, 100),
    runif(1000000, 0, 100),
    runif(1000000, 0, 100)
  )
  
  # Function to process each dataset
  process_data <- function(data) {
    # Simulate some computation
    result <- list(
      mean = mean(data),
      sd = sd(data),
      quantiles = quantile(data, probs = c(0.25, 0.5, 0.75)),
      length = length(data)
    )
    Sys.sleep(0.1)  # Simulate processing time
    return(result)
  }
  
  # Sequential processing
  start_time <- Sys.time()
  sequential_results <- lapply(data_list, process_data)
  sequential_time <- Sys.time() - start_time
  
  # Parallel processing using mclapply (Unix/Linux/Mac)
  if (.Platform$OS.type != "windows") {
    start_time <- Sys.time()
    parallel_results_mc <- mclapply(data_list, process_data, mc.cores = detectCores() - 1)
    parallel_time_mc <- Sys.time() - start_time
    cat("  Sequential time:", round(sequential_time, 3), "seconds\n")
    cat("  Parallel time (mclapply):", round(parallel_time_mc, 3), "seconds\n")
    cat("  Speedup:", round(sequential_time / parallel_time_mc, 2), "x\n\n")
  } else {
    # Windows alternative using parLapply
    cl <- makeCluster(detectCores() - 1)
    clusterEvalQ(cl, library(stats))
    start_time <- Sys.time()
    parallel_results_cl <- parLapply(cl, data_list, process_data)
    parallel_time_cl <- Sys.time() - start_time
    stopCluster(cl)
    
    cat("  Sequential time:", round(sequential_time, 3), "seconds\n")
    cat("  Parallel time (parLapply):", round(parallel_time_cl, 3), "seconds\n")
    cat("  Speedup:", round(sequential_time / parallel_time_cl, 2), "x\n\n")
  }
}

# Example 2: Future-based parallel processing
future_parallel_example <- function() {
  cat("2. Future-based Parallel Processing:\n")
  
  # Define a computationally intensive function
  compute_pi_monte_carlo <- function(n) {
    # Monte Carlo method to estimate pi
    x <- runif(n, -1, 1)
    y <- runif(n, -1, 1)
    inside_circle <- sum(x^2 + y^2 <= 1)
    pi_estimate <- 4 * inside_circle / n
    return(list(n = n, pi_estimate = pi_estimate, error = abs(pi_estimate - pi)))
  }
  
  # Parameters for different computations
  n_values <- c(1000000, 2000000, 3000000, 4000000)
  
  # Sequential execution
  start_time <- Sys.time()
  sequential_results <- lapply(n_values, compute_pi_monte_carlo)
  sequential_time <- Sys.time() - start_time
  
  # Parallel execution using future_lapply
  start_time <- Sys.time()
  parallel_results <- future_lapply(n_values, compute_pi_monte_carlo)
  parallel_time <- Sys.time() - start_time
  
  cat("  Sequential time:", round(sequential_time, 3), "seconds\n")
  cat("  Parallel time (future):", round(parallel_time, 3), "seconds\n")
  cat("  Speedup:", round(sequential_time / parallel_time, 2), "x\n")
  
  # Display results
  cat("  Pi estimates:\n")
  for (i in seq_along(parallel_results)) {
    result <- parallel_results[[i]]
    cat("    n =", result$n, "-> pi ≈", round(result$pi_estimate, 6), 
        "(error:", round(result$error, 6), ")\n")
  }
  cat("\n")
}

# Example 3: Async futures for non-blocking operations
async_future_example <- function() {
  cat("3. Asynchronous Futures (Non-blocking):\n")
  
  # Define some time-consuming operations
  slow_operation_1 <- function() {
    Sys.sleep(2)
    return(paste("Operation 1 completed at", Sys.time()))
  }
  
  slow_operation_2 <- function() {
    Sys.sleep(1.5)
    return(paste("Operation 2 completed at", Sys.time()))
  }
  
  slow_operation_3 <- function() {
    Sys.sleep(1)
    return(paste("Operation 3 completed at", Sys.time()))
  }
  
  # Start async operations
  cat("  Starting async operations at", as.character(Sys.time()), "\n")
  
  future1 <- future(slow_operation_1())
  future2 <- future(slow_operation_2())
  future3 <- future(slow_operation_3())
  
  # Do some other work while futures are computing
  cat("  Doing other work while futures compute...\n")
  for (i in 1:3) {
    cat("    Other work step", i, "at", as.character(Sys.time()), "\n")
    Sys.sleep(0.5)
  }
  
  # Collect results (this will block until all futures are resolved)
  cat("  Collecting results...\n")
  result1 <- value(future1)
  result2 <- value(future2)
  result3 <- value(future3)
  
  cat("  ", result1, "\n")
  cat("  ", result2, "\n")
  cat("  ", result3, "\n\n")
}

# Example 4: foreach parallel loops (if available)
foreach_parallel_example <- function() {
  if (!has_doParallel || !has_foreach) {
    cat("4. foreach/doParallel not available - skipping this example\n\n")
    return()
  }
  
  cat("4. Parallel foreach loops:\n")
  
  # Set up parallel backend
  cl <- makeCluster(detectCores() - 1)
  registerDoParallel(cl)
  
  # Define a function to process in parallel
  matrix_operations <- function(size) {
    # Create random matrix and perform operations
    m <- matrix(runif(size * size), nrow = size, ncol = size)
    eigenvals <- eigen(m, only.values = TRUE)$values
    return(list(
      size = size,
      determinant = det(m),
      trace = sum(diag(m)),
      max_eigenvalue = max(Re(eigenvals)),
      condition_number = kappa(m)
    ))
  }
  
  # Matrix sizes to process
  sizes <- c(100, 150, 200, 250, 300)
  
  # Sequential processing
  start_time <- Sys.time()
  sequential_results <- foreach(size = sizes) %do% {
    matrix_operations(size)
  }
  sequential_time <- Sys.time() - start_time
  
  # Parallel processing
  start_time <- Sys.time()
  parallel_results <- foreach(size = sizes, .packages = c("base")) %dopar% {
    matrix_operations(size)
  }
  parallel_time <- Sys.time() - start_time
  
  # Clean up
  stopCluster(cl)
  
  cat("  Sequential time:", round(sequential_time, 3), "seconds\n")
  cat("  Parallel time:", round(parallel_time, 3), "seconds\n")
  cat("  Speedup:", round(sequential_time / parallel_time, 2), "x\n")
  
  cat("  Matrix analysis results:\n")
  for (result in parallel_results) {
    cat("    Size", result$size, "x", result$size, 
        "- det:", round(result$determinant, 3),
        "- trace:", round(result$trace, 3),
        "- max eigenval:", round(result$max_eigenvalue, 3), "\n")
  }
  cat("\n")
}

# Example 5: Parallel data processing pipeline
data_pipeline_example <- function() {
  cat("5. Parallel Data Processing Pipeline:\n")
  
  # Simulate a large dataset
  set.seed(42)
  n_records <- 100000
  raw_data <- data.frame(
    id = 1:n_records,
    x = rnorm(n_records, 50, 15),
    y = rnorm(n_records, 30, 10),
    category = sample(c("A", "B", "C", "D"), n_records, replace = TRUE),
    timestamp = Sys.time() + runif(n_records, 0, 86400 * 30)  # 30 days
  )
  
  # Split data into chunks for parallel processing
  chunk_size <- 10000
  data_chunks <- split(raw_data, ceiling(seq_nrow(raw_data) / chunk_size))
  
  # Define processing function for each chunk
  process_chunk <- function(chunk) {
    # Simulate data cleaning and transformation
    processed <- chunk[complete.cases(chunk), ]  # Remove missing values
    processed$z <- processed$x * processed$y  # Create derived variable
    processed$x_normalized <- scale(processed$x)[, 1]  # Normalize x
    processed$y_normalized <- scale(processed$y)[, 1]  # Normalize y
    
    # Calculate chunk statistics
    stats <- list(
      n_records = nrow(processed),
      mean_x = mean(processed$x),
      mean_y = mean(processed$y),
      mean_z = mean(processed$z),
      category_counts = table(processed$category)
    )
    
    return(list(data = processed, stats = stats))
  }
  
  # Process chunks in parallel using future
  cat("  Processing", length(data_chunks), "data chunks in parallel...\n")
  
  start_time <- Sys.time()
  processed_chunks <- future_lapply(data_chunks, process_chunk)
  processing_time <- Sys.time() - start_time
  
  # Combine results
  combined_data <- do.call(rbind, lapply(processed_chunks, function(x) x$data))
  combined_stats <- lapply(processed_chunks, function(x) x$stats)
  
  cat("  Processing completed in", round(processing_time, 3), "seconds\n")
  cat("  Original records:", nrow(raw_data), "\n")
  cat("  Processed records:", nrow(combined_data), "\n")
  cat("  Average records per chunk:", mean(sapply(combined_stats, function(x) x$n_records)), "\n")
  
  # Aggregate statistics across chunks
  overall_stats <- list(
    total_records = nrow(combined_data),
    mean_x = mean(combined_data$x),
    mean_y = mean(combined_data$y),
    mean_z = mean(combined_data$z),
    category_distribution = prop.table(table(combined_data$category))
  )
  
  cat("  Overall statistics:\n")
  cat("    Mean X:", round(overall_stats$mean_x, 3), "\n")
  cat("    Mean Y:", round(overall_stats$mean_y, 3), "\n")
  cat("    Mean Z:", round(overall_stats$mean_z, 3), "\n")
  cat("    Category distribution:", paste(names(overall_stats$category_distribution), 
                                         round(overall_stats$category_distribution, 3), 
                                         collapse = ", "), "\n\n")
}

# Example 6: Error handling in parallel processing
error_handling_example <- function() {
  cat("6. Error Handling in Parallel Processing:\n")
  
  # Function that sometimes fails
  risky_computation <- function(x) {
    if (x == 3) {
      stop("Intentional error for x = 3")
    }
    return(x^2 + 2*x + 1)
  }
  
  # Data including a problematic value
  test_data <- 1:5
  
  # Try parallel processing with error handling
  cat("  Processing data with potential errors...\n")
  
  results <- future_lapply(test_data, function(x) {
    tryCatch({
      result <- risky_computation(x)
      list(input = x, output = result, success = TRUE, error = NULL)
    }, error = function(e) {
      list(input = x, output = NA, success = FALSE, error = e$message)
    })
  })
  
  # Display results
  for (result in results) {
    if (result$success) {
      cat("    Input:", result$input, "-> Output:", result$output, "(Success)\n")
    } else {
      cat("    Input:", result$input, "-> Error:", result$error, "\n")
    }
  }
  
  # Summary
  successful <- sum(sapply(results, function(x) x$success))
  failed <- length(results) - successful
  cat("  Summary: ", successful, "successful,", failed, "failed\n\n")
}

# Run all examples
main <- function() {
  parallel_basic_example()
  future_parallel_example()
  async_future_example()
  foreach_parallel_example()
  data_pipeline_example()
  error_handling_example()
  
  cat("Parallel processing demo completed!\n")
  cat("Note: Performance gains depend on the specific computation and system resources.\n")
}

# Execute main function if script is run directly
if (!interactive()) {
  main()
} else {
  cat("Run main() to execute all parallel processing examples\n")
}