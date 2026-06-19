output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint (hostname:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_host" {
  description = "RDS host address"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Master username (sensitive)"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "DB parameter group name"
  value       = aws_db_parameter_group.main.name
}

output "db_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.main.username}:PASSWORD@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}
