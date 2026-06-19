# Global Variables

variable "project_name" {
  description = "Project name for tagging and naming resources"
  type        = string
  default     = "saybaba-infrastructure"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# Azure Configuration
variable "azure_subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "azure_resource_group_location" {
  description = "Azure resource group location"
  type        = string
  default     = "East US"
}

variable "azure_vm_count" {
  description = "Number of Azure VMs to create"
  type        = number
  default     = 2
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "azure_vnet_cidr" {
  description = "CIDR block for Azure VNet"
  type        = string
  default     = "192.168.0.0/16"
}

# Database Configuration
variable "db_engine" {
  description = "Database engine (postgres, mysql, mariadb)"
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t2.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

# Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Owner       = "Cloud Team"
    CostCenter  = "Engineering"
    Compliance  = "SOC2"
  }
}
