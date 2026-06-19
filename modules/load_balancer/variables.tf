variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG"
  type        = list(string)
}

variable "instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "target_port" {
  description = "Target port for instances"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "launch_template_id" {
  description = "Launch template ID for ASG"
  type        = string
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Desired ASG capacity"
  type        = number
  default     = 2
}

variable "scale_up_threshold" {
  description = "CPU threshold to scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU threshold to scale down"
  type        = number
  default     = 30
}

variable "alarm_actions" {
  description = "SNS topic ARN for alarms"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
