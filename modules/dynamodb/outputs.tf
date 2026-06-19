output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.main.arn
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = aws_dynamodb_table.main.stream_arn
}

output "gsi_name" {
  description = "Global Secondary Index name"
  value       = aws_dynamodb_table.main.global_secondary_index[0].name
}
