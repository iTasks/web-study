# Configuring AWS Provider
provider "aws" {
  region = "us-west-1"
}

# Create a new IAM Role for Lambda@Edge
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole", 
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }, 
        "Effect": "Allow", 
        "Sid": ""
      }
    ]
  }
  EOF
}

# Create a new Lambda Function
resource "aws_lambda_function" "example" {
  filename      = "lambda_function_payload.zip"
  function_name = "example_lambda"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "exports.test"
 
  source_code_hash = "${filebase64sha256("lambda_function_payload.zip")}"
 
  runtime = "python3.7"
}

# Configuration for Lambda@Edge
resource "aws_cloudfront_distribution" "s3_distribution" {
 
  # supply your distribution config
  default_cache_behavior {
    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${aws_lambda_function.example.qualified_arn}"
    }
  }
}

# Create a GitHub webhook, and set it to trigger a build on Jenkins when a commit is pushed to the repo.
resource "github_repository_webhook" "webhook" {
  repository = "${github_repository.example.name}"
  
  configuration {
    url          = "https://${jenkins_url}/github-webhook/"
    content_type = "json"
    insecure_ssl = 0
    secret       = "${var.webhook_secret}"
  }

  events = ["push", "pull_request"]
}
