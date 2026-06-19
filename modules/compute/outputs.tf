output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.web[*].private_ip
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.web[*].public_ip
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.web.id
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.ec2_role.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app.name
}

output "instance_details" {
  description = "Detailed instance information"
  value = [
    for i, instance in aws_instance.web : {
      id            = instance.id
      private_ip    = instance.private_ip
      public_ip     = instance.public_ip
      subnet_id     = instance.subnet_id
      instance_type = instance.instance_type
    }
  ]
}
