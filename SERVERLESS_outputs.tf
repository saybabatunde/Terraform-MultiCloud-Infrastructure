# Serverless Outputs

# API Gateway
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api.api_endpoint
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "${module.api.api_endpoint}/health"
}

# Lambda
output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = module.functions.lambda_function_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.functions.lambda_function_name
}

# DynamoDB
output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.database.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.database.table_arn
}

# Summary
output "deployment_summary" {
  description = "Serverless Deployment Summary"
  value = {
    architecture     = "Serverless (Lambda + DynamoDB + API Gateway)"
    api_endpoint     = module.api.api_endpoint
    database         = module.database.table_name
    estimated_cost   = "FREE (within free tier limits)"
    features = [
      "Serverless REST API",
      "Auto-scaling (unlimited)",
      "Pay per request pricing",
      "Point-in-time recovery",
      "CloudWatch monitoring"
    ]
  }
}
