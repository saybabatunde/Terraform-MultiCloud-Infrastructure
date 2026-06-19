variable "project_name" {
  description = "Project name"
  type        = string
}

variable "engine" {
  description = "Database engine (postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "saybaba"
}

variable "master_username" {
  description = "Master database username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "master_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB deployment"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for database"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
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
