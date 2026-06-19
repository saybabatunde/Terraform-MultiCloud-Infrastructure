output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.main.id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "stage_name" {
  description = "Stage name"
  value       = aws_apigatewayv2_stage.main.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.api_logs.name
}
