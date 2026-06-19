# Main Terraform Configuration - Multi-Cloud Infrastructure
# Deploys AWS infrastructure with networking, compute, database, and load balancing

# AWS Networking Module
module "aws_networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.aws_vpc_cidr
  enable_nat_gateway   = var.aws_enable_nat_gateway
  allowed_ssh_cidrs    = ["0.0.0.0/0"] # Restrict in production

  tags = merge(
    var.tags,
    {
      Region = var.aws_region
    }
  )
}

# AWS Compute Module (EC2 Instances)
module "aws_compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  instance_count    = var.aws_instance_count
  instance_type     = var.aws_instance_type
  subnet_ids        = module.aws_networking.public_subnet_ids
  security_group_id = module.aws_networking.web_security_group_id
  associate_public_ip = true

  tags = var.tags

  depends_on = [module.aws_networking]
}

# AWS Database Module (RDS)
module "aws_database" {
  source = "./modules/database"

  project_name       = var.project_name
  engine             = var.db_engine
  engine_version     = "15.3"
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
  master_username    = var.db_username
  master_password    = var.db_password
  multi_az           = var.environment == "prod" ? true : false
  backup_retention_period = var.environment == "prod" ? 30 : 7

  private_subnet_ids = module.aws_networking.private_subnet_ids
  security_group_id  = module.aws_networking.database_security_group_id

  tags = var.tags

  depends_on = [module.aws_networking]
}

# AWS Load Balancer Module
module "aws_load_balancer" {
  source = "./modules/load_balancer"

  project_name       = var.project_name
  vpc_id             = module.aws_networking.vpc_id
  public_subnet_ids  = module.aws_networking.public_subnet_ids
  private_subnet_ids = module.aws_networking.private_subnet_ids
  instance_ids       = module.aws_compute.instance_ids
  security_group_id  = module.aws_networking.web_security_group_id
  launch_template_id = module.aws_compute.launch_template_id

  min_size         = var.environment == "prod" ? 2 : 1
  max_size         = var.environment == "prod" ? 10 : 3
  desired_capacity = var.environment == "prod" ? 3 : var.aws_instance_count

  tags = var.tags

  depends_on = [module.aws_compute, module.aws_networking]
}
