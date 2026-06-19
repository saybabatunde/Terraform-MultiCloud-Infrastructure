# Database Module - RDS

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db-subnet-group"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  iops                  = 3000
  backup_retention_period = var.backup_retention_period
  backup_window         = "03:00-04:00"
  maintenance_window    = "mon:04:00-mon:05:00"

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible       = false
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.project_name}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  iam_database_authentication_enabled = true
  performance_insights_enabled = true
  performance_insights_retention_period = 7
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn

  copy_tags_to_snapshot = true
  multi_az              = var.multi_az

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db"
    }
  )

  depends_on = [aws_iam_role_policy.rds_monitoring]
}

# RDS Monitoring IAM Role
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# RDS Monitoring IAM Policy
resource "aws_iam_role_policy" "rds_monitoring" {
  name = "${var.project_name}-rds-monitoring-policy"
  role = aws_iam_role.rds_monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# DB Parameter Group for custom configuration
resource "aws_db_parameter_group" "main" {
  family = "${var.engine}${split(".", var.engine_version)[0]}"
  name   = "${var.project_name}-params"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  alarm_name          = "${var.project_name}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when database CPU exceeds 80%"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "db_storage" {
  alarm_name          = "${var.project_name}-db-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2147483648" # 2GB in bytes
  alarm_description   = "Alert when free storage is below 2GB"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}
