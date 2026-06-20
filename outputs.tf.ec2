# Root Module Outputs

# AWS Networking Outputs
output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_networking.vpc_id
}

output "aws_vpc_cidr" {
  description = "AWS VPC CIDR block"
  value       = module.aws_networking.vpc_cidr
}

output "aws_public_subnet_ids" {
  description = "AWS Public Subnet IDs"
  value       = module.aws_networking.public_subnet_ids
}

output "aws_private_subnet_ids" {
  description = "AWS Private Subnet IDs"
  value       = module.aws_networking.private_subnet_ids
}

# AWS Compute Outputs
output "aws_instance_ids" {
  description = "AWS EC2 Instance IDs"
  value       = module.aws_compute.instance_ids
}

output "aws_instance_details" {
  description = "AWS EC2 Instance Details"
  value       = module.aws_compute.instance_details
}

output "aws_instance_public_ips" {
  description = "AWS EC2 Public IPs"
  value       = module.aws_compute.instance_public_ips
}

output "aws_instance_private_ips" {
  description = "AWS EC2 Private IPs"
  value       = module.aws_compute.instance_private_ips
}

# AWS Database Outputs
output "aws_db_endpoint" {
  description = "AWS RDS Database Endpoint"
  value       = module.aws_database.db_instance_endpoint
  sensitive   = true
}

output "aws_db_host" {
  description = "AWS RDS Database Host"
  value       = module.aws_database.db_host
}

output "aws_db_port" {
  description = "AWS RDS Database Port"
  value       = module.aws_database.db_port
}

output "aws_db_name" {
  description = "AWS RDS Database Name"
  value       = module.aws_database.db_name
}

output "aws_db_connection_string" {
  description = "AWS RDS Connection String (with PASSWORD placeholder)"
  value       = module.aws_database.db_connection_string
  sensitive   = true
}

# AWS Load Balancer Outputs
output "aws_alb_dns_name" {
  description = "AWS Application Load Balancer DNS Name"
  value       = module.aws_load_balancer.alb_dns_name
}

output "aws_application_url" {
  description = "Application URL via Load Balancer"
  value       = module.aws_load_balancer.application_url
}

output "aws_asg_name" {
  description = "AWS Auto Scaling Group Name"
  value       = module.aws_load_balancer.asg_name
}

# Summary Output
output "deployment_summary" {
  description = "Deployment Summary"
  value = {
    environment          = var.environment
    region              = var.aws_region
    vpc_id              = module.aws_networking.vpc_id
    instances_count     = var.aws_instance_count
    database_endpoint   = module.aws_database.db_host
    load_balancer_url   = module.aws_load_balancer.application_url
    auto_scaling_group  = module.aws_load_balancer.asg_name
  }
}
