# Serverless Main Configuration
# Uses Lambda, DynamoDB, and API Gateway instead of EC2/RDS/ALB

# Networking Module (for VPC if needed for Lambda VPC configuration)
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.aws_vpc_cidr
  enable_nat_gateway   = false  # Not needed for serverless
  allowed_ssh_cidrs    = []

  tags = var.tags
}

# DynamoDB Module (Serverless Database)
module "database" {
  source = "./modules/dynamodb"

  project_name = var.project_name

  tags = var.tags
}

# Lambda Module (Serverless Functions)
module "functions" {
  source = "./modules/lambda"

  project_name         = var.project_name
  environment          = var.environment
  dynamodb_table_arn   = module.database.table_arn

  tags = var.tags

  depends_on = [module.database]
}

# API Gateway Module
module "api" {
  source = "./modules/api"

  project_name            = var.project_name
  environment             = var.environment
  lambda_health_check_arn = module.functions.lambda_function_arn

  tags = var.tags

  depends_on = [module.functions]
}
