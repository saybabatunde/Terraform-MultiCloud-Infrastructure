output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.health_check.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.health_check.function_name
}

output "lambda_role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
