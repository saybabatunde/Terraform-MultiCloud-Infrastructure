variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs for instance placement"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for instances"
  type        = string
}

variable "associate_public_ip" {
  description = "Associate public IP address"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 80
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
