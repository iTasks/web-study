# R

## Purpose

This directory contains R programming language study materials and sample applications. R is a programming language and software environment specifically designed for statistical computing, data analysis, and graphics.

## Contents

### Pure Language Samples
- `samples/`: Core R language examples and applications
  - Web application development with Shiny
  - Parallel computing and threading
  - Webhook handling with Plumber API
  - Data processing and analysis
  - Statistical modeling and visualization

## Setup Instructions

### Prerequisites
- R 4.3.0 or higher
- RStudio (recommended IDE)

### Installation

#### On Ubuntu/Debian:
```bash
# Install R
sudo apt update
sudo apt install r-base r-base-dev

# Install additional build tools
sudo apt install build-essential libcurl4-openssl-dev libssl-dev libxml2-dev
```

#### On macOS:
```bash
# Install R using Homebrew
brew install r

# Or download from CRAN: https://cran.r-project.org/bin/macosx/
```

#### On Windows:
Download and install R from [CRAN](https://cran.r-project.org/bin/windows/base/)

### Installing Required Packages
```r
# Install essential packages for web development and parallel processing
install.packages(c(
  "shiny",         # Web applications
  "plumber",       # REST APIs and webhooks
  "future",        # Parallel computing
  "parallel",      # Parallel processing
  "httr",          # HTTP client
  "jsonlite",      # JSON processing
  "dplyr",         # Data manipulation
  "ggplot2",       # Data visualization
  "DT",            # Interactive tables
  "shinydashboard" # Dashboard framework
))
```

### Building and Running

#### For samples directory:
```bash
cd r/samples

# Run a specific R script
Rscript web_shiny_app.R

# Or open in R console
R
> source("web_shiny_app.R")
```

## Usage

### Running Sample Applications
```bash
# Run Shiny web application
cd r/samples
Rscript web_shiny_app.R

# Run Plumber API server
Rscript webhook_plumber_api.R

# Run parallel processing example
Rscript parallel_processing.R

# Run data analysis pipeline
Rscript data_analysis_pipeline.R
```

## Project Structure

```
r/
├── README.md                      # This file
└── samples/                       # Pure R language examples
    ├── web_shiny_app.R           # Shiny web application
    ├── webhook_plumber_api.R     # Plumber API with webhooks
    ├── parallel_processing.R     # Parallel computing examples
    ├── data_analysis_pipeline.R  # Data processing pipeline
    └── http_client.R             # HTTP client examples
```

## Key Learning Topics

- **Statistical Computing**: Advanced statistical analysis and modeling
- **Data Visualization**: Creating interactive and static visualizations
- **Web Applications**: Building interactive web apps with Shiny
- **API Development**: Creating REST APIs with Plumber
- **Parallel Computing**: Multi-core processing with future and parallel packages
- **Data Manipulation**: Advanced data wrangling with dplyr and tidyverse
- **Machine Learning**: Statistical learning and predictive modeling

## Contribution Guidelines

1. **Code Style**: Follow the [tidyverse style guide](https://style.tidyverse.org/)
2. **Documentation**: Include roxygen2 comments for functions
3. **Dependencies**: Clearly specify required packages in script headers
4. **Testing**: Use testthat for unit testing where appropriate
5. **Reproducibility**: Ensure examples work with specified R version and packages

### Adding New Samples
1. Place pure R examples in the `samples/` directory
2. Use descriptive file names with `.R` extension
3. Include required packages at the top of each script
4. Update this README with new content descriptions
5. Ensure all code runs successfully with specified dependencies

### Code Quality Standards
- Use meaningful variable and function names
- Include comments explaining complex operations
- Use appropriate data types and structures
- Handle errors gracefully with `tryCatch()` where needed
- Follow functional programming principles where applicable

## Resources and References

- [The R Project](https://www.r-project.org/)
- [CRAN - The Comprehensive R Archive Network](https://cran.r-project.org/)
- [RStudio Documentation](https://docs.rstudio.com/)
- [Shiny Documentation](https://shiny.rstudio.com/)
- [Plumber Documentation](https://www.rplumber.io/)
- [Tidyverse Documentation](https://www.tidyverse.org/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [Advanced R](https://adv-r.hadley.nz/)