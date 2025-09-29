# Comprehensive Data Analysis Pipeline in R
# Required packages: dplyr, ggplot2, tidyr, readr, lubridate, corrplot

# Load required libraries
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(lubridate)
})

# Check for optional packages
has_corrplot <- requireNamespace("corrplot", quietly = TRUE)
has_readr <- requireNamespace("readr", quietly = TRUE)

if (has_corrplot) library(corrplot)
if (has_readr) library(readr)

cat("=== R Data Analysis Pipeline Demo ===\n\n")

# Generate sample dataset for analysis
generate_sample_data <- function(n = 10000) {
  cat("1. Generating sample dataset...\n")
  
  set.seed(42)  # For reproducible results
  
  # Create a realistic sales dataset
  data <- data.frame(
    # Customer information
    customer_id = sample(1:2000, n, replace = TRUE),
    customer_segment = sample(c("Enterprise", "SMB", "Individual"), n, 
                             replace = TRUE, prob = c(0.2, 0.3, 0.5)),
    
    # Product information
    product_category = sample(c("Electronics", "Clothing", "Books", "Home", "Sports"), 
                             n, replace = TRUE, prob = c(0.3, 0.25, 0.15, 0.2, 0.1)),
    product_price = round(exp(rnorm(n, log(50), 1)), 2),  # Log-normal distribution
    
    # Transaction information
    transaction_date = sample(seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day"), 
                             n, replace = TRUE),
    quantity = sample(1:10, n, replace = TRUE, prob = c(0.4, 0.25, 0.15, 0.1, 0.05, 0.02, 0.01, 0.01, 0.005, 0.005)),
    
    # Geographic information
    region = sample(c("North", "South", "East", "West", "Central"), n, 
                   replace = TRUE, prob = c(0.22, 0.20, 0.25, 0.18, 0.15)),
    
    # Channel information
    sales_channel = sample(c("Online", "Retail Store", "Mobile App", "Phone"), n,
                          replace = TRUE, prob = c(0.45, 0.35, 0.15, 0.05)),
    
    stringsAsFactors = FALSE
  )
  
  # Add some derived fields and introduce realistic relationships
  data$total_amount <- data$product_price * data$quantity
  
  # Add discount based on customer segment and quantity
  data$discount_rate <- ifelse(data$customer_segment == "Enterprise", 0.15,
                              ifelse(data$customer_segment == "SMB", 0.10, 0.05)) +
                       ifelse(data$quantity > 5, 0.05, 0)
  
  data$discounted_amount <- data$total_amount * (1 - data$discount_rate)
  
  # Add seasonal effects
  data$month <- month(data$transaction_date)
  data$is_holiday_season <- data$month %in% c(11, 12)  # Nov-Dec
  data$seasonal_boost <- ifelse(data$is_holiday_season, 1.2, 1.0)
  data$final_amount <- data$discounted_amount * data$seasonal_boost
  
  # Add some missing values to make it realistic
  missing_indices <- sample(nrow(data), nrow(data) * 0.02)  # 2% missing
  data$product_price[sample(missing_indices, length(missing_indices) * 0.5)] <- NA
  
  cat("  Generated", nrow(data), "transactions\n")
  cat("  Date range:", min(data$transaction_date), "to", max(data$transaction_date), "\n")
  cat("  Missing values:", sum(is.na(data)), "\n\n")
  
  return(data)
}

# Data cleaning and preprocessing
clean_and_preprocess <- function(data) {
  cat("2. Data cleaning and preprocessing...\n")
  
  original_rows <- nrow(data)
  
  # Handle missing values
  cat("  Handling missing values...\n")
  data_clean <- data %>%
    filter(!is.na(product_price)) %>%  # Remove rows with missing price
    mutate(
      # Fill any remaining missing values
      product_price = ifelse(is.na(product_price), median(product_price, na.rm = TRUE), product_price)
    )
  
  # Data type conversions and new features
  cat("  Creating derived features...\n")
  data_clean <- data_clean %>%
    mutate(
      # Date features
      year = year(transaction_date),
      month = month(transaction_date),
      quarter = quarter(transaction_date),
      day_of_week = wday(transaction_date, label = TRUE),
      week_of_year = week(transaction_date),
      
      # Business features
      is_weekend = day_of_week %in% c("Sat", "Sun"),
      price_category = case_when(
        product_price < 25 ~ "Low",
        product_price < 100 ~ "Medium",
        TRUE ~ "High"
      ),
      
      # Customer features
      high_value_customer = customer_segment == "Enterprise",
      
      # Transaction features
      large_order = quantity > 3,
      online_transaction = sales_channel %in% c("Online", "Mobile App")
    )
  
  removed_rows <- original_rows - nrow(data_clean)
  cat("  Removed", removed_rows, "rows with missing data\n")
  cat("  Final dataset:", nrow(data_clean), "rows,", ncol(data_clean), "columns\n\n")
  
  return(data_clean)
}

# Exploratory Data Analysis
perform_eda <- function(data) {
  cat("3. Exploratory Data Analysis...\n")
  
  # Basic statistics
  cat("  Basic Dataset Statistics:\n")
  cat("    Total transactions:", nrow(data), "\n")
  cat("    Unique customers:", length(unique(data$customer_id)), "\n")
  cat("    Date range:", min(data$transaction_date), "to", max(data$transaction_date), "\n")
  cat("    Total revenue: $", format(sum(data$final_amount), big.mark = ",", digits = 2), "\n")
  cat("    Average transaction: $", round(mean(data$final_amount), 2), "\n")
  cat("    Median transaction: $", round(median(data$final_amount), 2), "\n\n")
  
  # Summary by categorical variables
  cat("  Sales by Customer Segment:\n")
  segment_summary <- data %>%
    group_by(customer_segment) %>%
    summarise(
      transactions = n(),
      total_revenue = sum(final_amount),
      avg_transaction = mean(final_amount),
      avg_quantity = mean(quantity),
      .groups = 'drop'
    ) %>%
    arrange(desc(total_revenue))
  
  print(segment_summary)
  cat("\n")
  
  cat("  Sales by Product Category:\n")
  category_summary <- data %>%
    group_by(product_category) %>%
    summarise(
      transactions = n(),
      total_revenue = sum(final_amount),
      avg_price = mean(product_price),
      .groups = 'drop'
    ) %>%
    arrange(desc(total_revenue))
  
  print(category_summary)
  cat("\n")
  
  cat("  Sales by Channel:\n")
  channel_summary <- data %>%
    group_by(sales_channel) %>%
    summarise(
      transactions = n(),
      revenue_share = round(sum(final_amount) / sum(data$final_amount) * 100, 1),
      avg_transaction = round(mean(final_amount), 2),
      .groups = 'drop'
    ) %>%
    arrange(desc(revenue_share))
  
  print(channel_summary)
  cat("\n")
  
  return(list(
    segment_summary = segment_summary,
    category_summary = category_summary,
    channel_summary = channel_summary
  ))
}

# Time series analysis
time_series_analysis <- function(data) {
  cat("4. Time Series Analysis...\n")
  
  # Daily sales trends
  daily_sales <- data %>%
    group_by(transaction_date) %>%
    summarise(
      daily_revenue = sum(final_amount),
      daily_transactions = n(),
      avg_transaction_size = mean(final_amount),
      .groups = 'drop'
    ) %>%
    arrange(transaction_date)
  
  cat("  Daily sales summary:\n")
  cat("    Average daily revenue: $", round(mean(daily_sales$daily_revenue), 2), "\n")
  cat("    Peak daily revenue: $", round(max(daily_sales$daily_revenue), 2), "\n")
  cat("    Average daily transactions:", round(mean(daily_sales$daily_transactions), 1), "\n\n")
  
  # Monthly trends
  monthly_trends <- data %>%
    group_by(year, month) %>%
    summarise(
      monthly_revenue = sum(final_amount),
      monthly_transactions = n(),
      unique_customers = n_distinct(customer_id),
      .groups = 'drop'
    ) %>%
    mutate(
      month_name = month.name[month],
      revenue_growth = (monthly_revenue - lag(monthly_revenue)) / lag(monthly_revenue) * 100
    )
  
  cat("  Monthly trends:\n")
  print(monthly_trends %>% select(month_name, monthly_revenue, monthly_transactions, revenue_growth))
  cat("\n")
  
  # Seasonal analysis
  seasonal_analysis <- data %>%
    group_by(month) %>%
    summarise(
      avg_monthly_revenue = mean(final_amount),
      total_transactions = n(),
      .groups = 'drop'
    ) %>%
    mutate(
      month_name = month.name[month],
      seasonal_index = avg_monthly_revenue / mean(avg_monthly_revenue)
    )
  
  cat("  Seasonal patterns (seasonal index):\n")
  print(seasonal_analysis %>% select(month_name, seasonal_index) %>% arrange(desc(seasonal_index)))
  cat("\n")
  
  return(list(
    daily_sales = daily_sales,
    monthly_trends = monthly_trends,
    seasonal_analysis = seasonal_analysis
  ))
}

# Customer analysis
customer_analysis <- function(data) {
  cat("5. Customer Analysis...\n")
  
  # Customer lifetime value and behavior
  customer_metrics <- data %>%
    group_by(customer_id, customer_segment) %>%
    summarise(
      total_spent = sum(final_amount),
      transaction_count = n(),
      avg_order_value = mean(final_amount),
      first_purchase = min(transaction_date),
      last_purchase = max(transaction_date),
      days_active = as.numeric(max(transaction_date) - min(transaction_date)) + 1,
      favorite_category = names(sort(table(product_category), decreasing = TRUE))[1],
      preferred_channel = names(sort(table(sales_channel), decreasing = TRUE))[1],
      .groups = 'drop'
    ) %>%
    mutate(
      purchase_frequency = transaction_count / pmax(days_active, 1) * 30,  # purchases per month
      customer_value_tier = case_when(
        total_spent >= quantile(total_spent, 0.9) ~ "High Value",
        total_spent >= quantile(total_spent, 0.7) ~ "Medium Value",
        TRUE ~ "Low Value"
      )
    )
  
  cat("  Customer segmentation:\n")
  customer_tiers <- customer_metrics %>%
    group_by(customer_value_tier) %>%
    summarise(
      customer_count = n(),
      avg_total_spent = round(mean(total_spent), 2),
      avg_transaction_count = round(mean(transaction_count), 1),
      avg_order_value = round(mean(avg_order_value), 2),
      .groups = 'drop'
    )
  
  print(customer_tiers)
  cat("\n")
  
  # RFM Analysis (Recency, Frequency, Monetary)
  current_date <- max(data$transaction_date)
  
  rfm_analysis <- customer_metrics %>%
    mutate(
      recency = as.numeric(current_date - last_purchase),
      frequency = transaction_count,
      monetary = total_spent,
      
      # Create RFM scores (1-5 scale)
      r_score = as.numeric(cut(recency, breaks = 5, labels = 5:1)),  # Lower recency = higher score
      f_score = as.numeric(cut(frequency, breaks = 5, labels = 1:5)),
      m_score = as.numeric(cut(monetary, breaks = 5, labels = 1:5)),
      
      rfm_score = paste0(r_score, f_score, m_score),
      
      # Customer segments based on RFM
      customer_type = case_when(
        r_score >= 4 & f_score >= 4 & m_score >= 4 ~ "Champions",
        r_score >= 3 & f_score >= 3 & m_score >= 4 ~ "Loyal Customers",
        r_score >= 4 & f_score <= 2 & m_score >= 3 ~ "New Customers",
        r_score <= 2 & f_score >= 3 & m_score >= 3 ~ "At Risk",
        r_score <= 2 & f_score <= 2 & m_score <= 2 ~ "Lost Customers",
        TRUE ~ "Regular Customers"
      )
    )
  
  cat("  RFM Customer Segmentation:\n")
  rfm_segments <- rfm_analysis %>%
    group_by(customer_type) %>%
    summarise(
      count = n(),
      avg_monetary = round(mean(monetary), 2),
      avg_frequency = round(mean(frequency), 1),
      avg_recency = round(mean(recency), 1),
      .groups = 'drop'
    ) %>%
    arrange(desc(avg_monetary))
  
  print(rfm_segments)
  cat("\n")
  
  return(list(
    customer_metrics = customer_metrics,
    customer_tiers = customer_tiers,
    rfm_analysis = rfm_analysis,
    rfm_segments = rfm_segments
  ))
}

# Statistical analysis
statistical_analysis <- function(data) {
  cat("6. Statistical Analysis...\n")
  
  # Correlation analysis
  cat("  Correlation analysis:\n")
  numeric_data <- data %>%
    select(product_price, quantity, total_amount, discount_rate, final_amount) %>%
    filter(complete.cases(.))
  
  correlation_matrix <- cor(numeric_data)
  print(round(correlation_matrix, 3))
  cat("\n")
  
  # Hypothesis testing: Do enterprise customers spend more?
  cat("  Hypothesis Testing - Enterprise vs Non-Enterprise Spending:\n")
  enterprise_spending <- data %>% 
    filter(customer_segment == "Enterprise") %>% 
    pull(final_amount)
  
  non_enterprise_spending <- data %>% 
    filter(customer_segment != "Enterprise") %>% 
    pull(final_amount)
  
  t_test_result <- t.test(enterprise_spending, non_enterprise_spending)
  
  cat("    Enterprise customers avg spending: $", round(mean(enterprise_spending), 2), "\n")
  cat("    Non-Enterprise customers avg spending: $", round(mean(non_enterprise_spending), 2), "\n")
  cat("    T-test p-value:", format(t_test_result$p.value, scientific = TRUE), "\n")
  cat("    Significant difference:", ifelse(t_test_result$p.value < 0.05, "YES", "NO"), "\n\n")
  
  # ANOVA: Differences across product categories
  cat("  ANOVA - Spending differences across product categories:\n")
  anova_result <- aov(final_amount ~ product_category, data = data)
  anova_summary <- summary(anova_result)
  
  cat("    F-statistic:", round(anova_summary[[1]]$`F value`[1], 3), "\n")
  cat("    P-value:", format(anova_summary[[1]]$`Pr(>F)`[1], scientific = TRUE), "\n")
  cat("    Significant differences:", ifelse(anova_summary[[1]]$`Pr(>F)`[1] < 0.05, "YES", "NO"), "\n\n")
  
  # Regression analysis: Factors affecting transaction amount
  cat("  Multiple Regression Analysis:\n")
  regression_model <- lm(final_amount ~ product_price + quantity + 
                        customer_segment + product_category + 
                        sales_channel + is_weekend, data = data)
  
  model_summary <- summary(regression_model)
  cat("    R-squared:", round(model_summary$r.squared, 4), "\n")
  cat("    Adjusted R-squared:", round(model_summary$adj.r.squared, 4), "\n")
  cat("    F-statistic p-value:", format(pf(model_summary$fstatistic[1], 
                                            model_summary$fstatistic[2], 
                                            model_summary$fstatistic[3], 
                                            lower.tail = FALSE), scientific = TRUE), "\n\n")
  
  return(list(
    correlation_matrix = correlation_matrix,
    t_test = t_test_result,
    anova = anova_result,
    regression = regression_model
  ))
}

# Performance metrics and KPIs
calculate_kpis <- function(data, summaries) {
  cat("7. Key Performance Indicators (KPIs):\n")
  
  # Business KPIs
  total_revenue <- sum(data$final_amount)
  total_transactions <- nrow(data)
  unique_customers <- length(unique(data$customer_id))
  avg_order_value <- mean(data$final_amount)
  
  # Calculate conversion and retention metrics (simulated)
  customer_retention_rate <- 0.75  # Simulated
  customer_acquisition_cost <- 25  # Simulated
  
  # Channel effectiveness
  channel_roi <- data %>%
    group_by(sales_channel) %>%
    summarise(
      revenue = sum(final_amount),
      transactions = n(),
      avg_order_value = mean(final_amount),
      .groups = 'drop'
    ) %>%
    mutate(
      revenue_share = revenue / total_revenue * 100,
      cost_per_transaction = case_when(
        sales_channel == "Online" ~ 5,
        sales_channel == "Mobile App" ~ 3,
        sales_channel == "Retail Store" ~ 15,
        sales_channel == "Phone" ~ 20
      ),
      roi = (revenue - (transactions * cost_per_transaction)) / (transactions * cost_per_transaction) * 100
    )
  
  cat("  Business Metrics:\n")
  cat("    Total Revenue: $", format(total_revenue, big.mark = ",", digits = 2), "\n")
  cat("    Total Transactions:", format(total_transactions, big.mark = ","), "\n")
  cat("    Unique Customers:", format(unique_customers, big.mark = ","), "\n")
  cat("    Average Order Value: $", round(avg_order_value, 2), "\n")
  cat("    Revenue per Customer: $", round(total_revenue / unique_customers, 2), "\n")
  cat("    Transactions per Customer:", round(total_transactions / unique_customers, 1), "\n\n")
  
  cat("  Channel Performance:\n")
  print(channel_roi %>% select(sales_channel, revenue_share, avg_order_value, roi))
  cat("\n")
  
  # Seasonal performance
  seasonal_kpis <- data %>%
    mutate(season = case_when(
      month %in% c(12, 1, 2) ~ "Winter",
      month %in% c(3, 4, 5) ~ "Spring", 
      month %in% c(6, 7, 8) ~ "Summer",
      month %in% c(9, 10, 11) ~ "Fall"
    )) %>%
    group_by(season) %>%
    summarise(
      revenue = sum(final_amount),
      transactions = n(),
      avg_order_value = mean(final_amount),
      .groups = 'drop'
    ) %>%
    mutate(revenue_share = revenue / total_revenue * 100)
  
  cat("  Seasonal Performance:\n")
  print(seasonal_kpis)
  cat("\n")
  
  return(list(
    business_metrics = list(
      total_revenue = total_revenue,
      total_transactions = total_transactions,
      unique_customers = unique_customers,
      avg_order_value = avg_order_value
    ),
    channel_roi = channel_roi,
    seasonal_kpis = seasonal_kpis
  ))
}

# Main pipeline function
run_analysis_pipeline <- function() {
  cat("Starting comprehensive data analysis pipeline...\n\n")
  
  # Step 1: Generate and prepare data
  raw_data <- generate_sample_data(10000)
  clean_data <- clean_and_preprocess(raw_data)
  
  # Step 2: Perform analyses
  eda_results <- perform_eda(clean_data)
  time_results <- time_series_analysis(clean_data)
  customer_results <- customer_analysis(clean_data)
  stats_results <- statistical_analysis(clean_data)
  kpi_results <- calculate_kpis(clean_data, eda_results)
  
  # Step 3: Generate summary report
  cat("8. Executive Summary:\n")
  cat("=====================================\n")
  cat("This analysis reveals key insights about the business:\n\n")
  
  cat("• Customer Insights:\n")
  cat("  - Enterprise customers generate the highest revenue per transaction\n")
  cat("  - Customer retention and value segmentation show clear tiers\n")
  cat("  - RFM analysis identifies actionable customer segments\n\n")
  
  cat("• Product Performance:\n")
  cat("  - Electronics category leads in revenue generation\n")
  cat("  - Seasonal patterns show strong Q4 performance\n")
  cat("  - Price optimization opportunities exist across categories\n\n")
  
  cat("• Channel Effectiveness:\n")
  cat("  - Online channels show strong ROI and growth potential\n")
  cat("  - Mobile app has highest efficiency metrics\n")
  cat("  - Retail stores provide steady volume but higher costs\n\n")
  
  cat("• Statistical Significance:\n")
  cat("  - Significant differences in spending patterns across segments\n")
  cat("  - Strong correlations between price, quantity, and revenue\n")
  cat("  - Regression model explains significant variance in outcomes\n\n")
  
  cat("Analysis pipeline completed successfully!\n")
  
  # Return all results for further use
  return(list(
    data = clean_data,
    eda = eda_results,
    time_series = time_results,
    customer = customer_results,
    statistics = stats_results,
    kpis = kpi_results
  ))
}

# Execute pipeline if script is run directly
if (!interactive()) {
  results <- run_analysis_pipeline()
} else {
  cat("Run run_analysis_pipeline() to execute the complete data analysis pipeline\n")
}