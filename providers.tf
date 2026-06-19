terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Uncomment for remote state (production use)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "multi-cloud/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = true
      skip_shutdown_and_force_delete        = false
    }
  }

  skip_provider_registration = false
  subscription_id            = var.azure_subscription_id
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for Azure client config
data "azurerm_client_config" "current" {}
