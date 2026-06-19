# DynamoDB Module - Serverless Database

# Main Application Table
resource "aws_dynamodb_table" "main" {
  name           = "${var.project_name}-table"
  billing_mode   = "PAY_PER_REQUEST" # Serverless - pay only for what you use
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Global Secondary Index for queries
  global_secondary_index {
    name            = "GSI1"
    hash_key        = "GSI1PK"
    range_key       = "GSI1SK"
    projection_type = "ALL"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  # Point in time recovery (automatic backups)
  point_in_time_recovery_specification {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption_specification {
    enabled = true
  }

  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }

  stream_specification {
    stream_view_type = "NEW_AND_OLD_IMAGES"
  }

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "consumed_write_capacity" {
  alarm_name          = "${var.project_name}-high-write-capacity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "Alert when write capacity usage is high"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "consumed_read_capacity" {
  alarm_name          = "${var.project_name}-high-read-capacity"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "Alert when read capacity usage is high"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "user_errors" {
  alarm_name          = "${var.project_name}-dynamodb-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alert when DynamoDB returns user errors"

  dimensions = {
    TableName = aws_dynamodb_table.main.name
  }

  tags = var.tags
}
