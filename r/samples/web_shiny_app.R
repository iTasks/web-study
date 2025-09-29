# Web Application with Shiny
# Required packages: shiny, DT, ggplot2, dplyr

library(shiny)
library(DT)
library(ggplot2)
library(dplyr)

# Sample data for the application
sample_data <- data.frame(
  Name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
  Age = c(25, 30, 35, 28, 32),
  Department = c("Engineering", "Marketing", "Engineering", "Sales", "Engineering"),
  Salary = c(75000, 65000, 85000, 60000, 80000),
  Performance = c(8.5, 7.2, 9.1, 7.8, 8.8),
  stringsAsFactors = FALSE
)

# Define UI
ui <- fluidPage(
  titlePanel("Employee Dashboard - R Shiny Web Application"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Filters"),
      
      # Department filter
      selectInput("department",
                  "Select Department:",
                  choices = c("All", unique(sample_data$Department)),
                  selected = "All"),
      
      # Age range filter
      sliderInput("age_range",
                  "Age Range:",
                  min = min(sample_data$Age),
                  max = max(sample_data$Age),
                  value = c(min(sample_data$Age), max(sample_data$Age))),
      
      # Performance filter
      numericInput("min_performance",
                   "Minimum Performance Score:",
                   value = 0,
                   min = 0,
                   max = 10,
                   step = 0.1),
      
      hr(),
      
      # Add new employee form
      h3("Add New Employee"),
      textInput("new_name", "Name:", ""),
      numericInput("new_age", "Age:", value = 25, min = 18, max = 100),
      selectInput("new_dept", "Department:", 
                  choices = unique(sample_data$Department)),
      numericInput("new_salary", "Salary:", value = 50000, min = 0),
      numericInput("new_performance", "Performance:", 
                   value = 5.0, min = 0, max = 10, step = 0.1),
      
      actionButton("add_employee", "Add Employee", 
                   class = "btn-primary")
    ),
    
    mainPanel(
      tabsetPanel(
        # Data table tab
        tabPanel("Employee Data",
                 h3("Employee Information"),
                 DTOutput("employee_table"),
                 br(),
                 h4("Summary Statistics"),
                 verbatimTextOutput("summary_stats")
        ),
        
        # Visualizations tab
        tabPanel("Visualizations",
                 h3("Data Visualizations"),
                 fluidRow(
                   column(6, plotOutput("salary_plot")),
                   column(6, plotOutput("performance_plot"))
                 ),
                 br(),
                 fluidRow(
                   column(12, plotOutput("department_analysis"))
                 )
        ),
        
        # Analytics tab
        tabPanel("Analytics",
                 h3("Advanced Analytics"),
                 fluidRow(
                   column(6,
                          h4("Correlation Analysis"),
                          plotOutput("correlation_plot")
                   ),
                   column(6,
                          h4("Department Metrics"),
                          tableOutput("dept_metrics")
                   )
                 ),
                 br(),
                 fluidRow(
                   column(12,
                          h4("Performance Distribution"),
                          plotOutput("performance_distribution")
                   )
                 )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Reactive values to store data
  values <- reactiveValues(
    data = sample_data
  )
  
  # Filtered data based on inputs
  filtered_data <- reactive({
    data <- values$data
    
    # Filter by department
    if (input$department != "All") {
      data <- data[data$Department == input$department, ]
    }
    
    # Filter by age range
    data <- data[data$Age >= input$age_range[1] & data$Age <= input$age_range[2], ]
    
    # Filter by performance
    data <- data[data$Performance >= input$min_performance, ]
    
    return(data)
  })
  
  # Add new employee
  observeEvent(input$add_employee, {
    if (input$new_name != "") {
      new_row <- data.frame(
        Name = input$new_name,
        Age = input$new_age,
        Department = input$new_dept,
        Salary = input$new_salary,
        Performance = input$new_performance,
        stringsAsFactors = FALSE
      )
      
      values$data <- rbind(values$data, new_row)
      
      # Clear form
      updateTextInput(session, "new_name", value = "")
      updateNumericInput(session, "new_age", value = 25)
      updateNumericInput(session, "new_salary", value = 50000)
      updateNumericInput(session, "new_performance", value = 5.0)
      
      showNotification("Employee added successfully!", type = "success")
    } else {
      showNotification("Please enter a name!", type = "error")
    }
  })
  
  # Employee table
  output$employee_table <- renderDT({
    datatable(filtered_data(), 
              options = list(pageLength = 10, scrollX = TRUE),
              filter = "top")
  })
  
  # Summary statistics
  output$summary_stats <- renderText({
    data <- filtered_data()
    if (nrow(data) > 0) {
      paste(
        "Total Employees:", nrow(data), "\n",
        "Average Age:", round(mean(data$Age), 1), "\n",
        "Average Salary: $", format(round(mean(data$Salary), 0), big.mark = ","), "\n",
        "Average Performance:", round(mean(data$Performance), 2), "\n",
        "Departments:", length(unique(data$Department))
      )
    } else {
      "No data matches the current filters."
    }
  })
  
  # Salary visualization
  output$salary_plot <- renderPlot({
    data <- filtered_data()
    if (nrow(data) > 0) {
      ggplot(data, aes(x = Department, y = Salary, fill = Department)) +
        geom_boxplot() +
        theme_minimal() +
        labs(title = "Salary Distribution by Department",
             y = "Salary ($)") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
  
  # Performance visualization
  output$performance_plot <- renderPlot({
    data <- filtered_data()
    if (nrow(data) > 0) {
      ggplot(data, aes(x = Age, y = Performance, color = Department, size = Salary)) +
        geom_point(alpha = 0.7) +
        theme_minimal() +
        labs(title = "Performance vs Age by Department",
             x = "Age", y = "Performance Score") +
        scale_size_continuous(name = "Salary", labels = scales::dollar)
    }
  })
  
  # Department analysis
  output$department_analysis <- renderPlot({
    data <- filtered_data()
    if (nrow(data) > 0) {
      dept_summary <- data %>%
        group_by(Department) %>%
        summarise(
          Count = n(),
          Avg_Salary = mean(Salary),
          Avg_Performance = mean(Performance),
          .groups = 'drop'
        )
      
      ggplot(dept_summary, aes(x = Department)) +
        geom_col(aes(y = Count), fill = "steelblue", alpha = 0.7) +
        geom_text(aes(y = Count + 0.1, label = Count), vjust = 0) +
        theme_minimal() +
        labs(title = "Employee Count by Department",
             y = "Number of Employees") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })
  
  # Correlation plot
  output$correlation_plot <- renderPlot({
    data <- filtered_data()
    if (nrow(data) > 0 && nrow(data) > 1) {
      ggplot(data, aes(x = Salary, y = Performance)) +
        geom_point(aes(color = Department), size = 3, alpha = 0.7) +
        geom_smooth(method = "lm", se = TRUE, color = "black") +
        theme_minimal() +
        labs(title = "Salary vs Performance Correlation",
             x = "Salary ($)", y = "Performance Score") +
        scale_x_continuous(labels = scales::dollar)
    }
  })
  
  # Department metrics table
  output$dept_metrics <- renderTable({
    data <- filtered_data()
    if (nrow(data) > 0) {
      data %>%
        group_by(Department) %>%
        summarise(
          Employees = n(),
          `Avg Salary` = scales::dollar(round(mean(Salary), 0)),
          `Avg Performance` = round(mean(Performance), 2),
          `Min Age` = min(Age),
          `Max Age` = max(Age),
          .groups = 'drop'
        )
    }
  })
  
  # Performance distribution
  output$performance_distribution <- renderPlot({
    data <- filtered_data()
    if (nrow(data) > 0) {
      ggplot(data, aes(x = Performance)) +
        geom_histogram(bins = 10, fill = "lightblue", color = "black", alpha = 0.7) +
        facet_wrap(~Department) +
        theme_minimal() +
        labs(title = "Performance Score Distribution by Department",
             x = "Performance Score", y = "Frequency")
    }
  })
}

# Run the application
if (interactive()) {
  shinyApp(ui = ui, server = server)
} else {
  # For running from command line or script
  runApp(shinyApp(ui = ui, server = server), host = "0.0.0.0", port = 3838)
}