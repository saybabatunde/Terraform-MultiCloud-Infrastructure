# 🏗️ Terraform Multi-Cloud Infrastructure

A production-ready, enterprise-grade infrastructure-as-code project demonstrating **AWS** deployment with complete networking, compute, database, and load balancing using **Terraform**.

## 📋 Overview

This project showcases **real-world cloud infrastructure** with:
- ✅ **Modular Terraform Architecture** - Reusable, maintainable code
- ✅ **Multi-Environment Support** - Dev, Staging, Production configurations
- ✅ **AWS Infrastructure** - VPC, EC2, RDS, ALB, Auto-Scaling
- ✅ **Production-Ready Features** - Monitoring, logging, security groups, backup strategies
- ✅ **Infrastructure as Code Best Practices** - State management, variables, outputs, tagging

## 🎯 What This Demonstrates

### Core Cloud Skills
- **Infrastructure Provisioning** - Programmatic resource creation at scale
- **Network Design** - VPCs, subnets, routing, NAT gateways, security groups
- **High Availability** - Load balancing, auto-scaling, multi-AZ databases
- **Security** - IAM roles, security groups, encrypted storage, monitoring
- **Cost Optimization** - Right-sizing instances, efficient resource tagging
- **Disaster Recovery** - Automated backups, multi-AZ failover
- **Monitoring & Alerts** - CloudWatch metrics, alarms, auto-scaling triggers

### Terraform Best Practices
- Modular module structure (`modules/`, reusable across projects)
- Environment-specific configurations (`environments/dev|staging|prod`)
- Sensitive data handling (passwords, API keys)
- Resource tagging strategy
- Output management for integration
- State file best practices (remote backend commented out)

## 📁 Project Structure

```
Terraform-MultiCloud-Infrastructure/
├── providers.tf                    # AWS provider configuration
├── variables.tf                    # Global variables
├── main.tf                         # Module orchestration
├── outputs.tf                      # Root module outputs
│
├── modules/                        # Reusable modules
│   ├── networking/                 # VPC, subnets, routing, security groups
│   │   ├── aws_networking.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/                    # EC2 instances, IAM roles, CloudWatch
│   │   ├── main.tf
│   │   ├── user_data.sh
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── database/                   # RDS PostgreSQL, monitoring, backups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── load_balancer/              # ALB, target groups, ASG, auto-scaling
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/                   # Environment configurations
│   ├── dev/
│   │   └── terraform.tfvars       # Development: minimal, cost-optimized
│   ├── staging/
│   │   └── terraform.tfvars       # Staging: production-like
│   └── prod/
│       └── terraform.tfvars       # Production: HA, multi-AZ, backups
│
└── README.md                       # This file
```

## 🚀 Quick Start

### Prerequisites
```bash
# Install Terraform
brew install terraform          # macOS
choco install terraform         # Windows
apt-get install terraform       # Linux

# Verify installation
terraform version              # Should be >= 1.0

# Configure AWS credentials
aws configure                  # Enter AWS Access Key & Secret Key
```

### Deploy Development Environment

```bash
# Navigate to project
cd Terraform-MultiCloud-Infrastructure

# Initialize Terraform (downloads providers, sets up backend)
terraform init

# Plan deployment (preview what will be created)
terraform plan -var-file=environments/dev/terraform.tfvars

# Apply deployment (create actual resources)
terraform apply -var-file=environments/dev/terraform.tfvars

# View outputs (ALB URL, database endpoint, etc.)
terraform output
```

### Deploy Staging Environment

```bash
# Change to staging workspace
terraform workspace new staging || terraform workspace select staging

# Deploy staging
terraform plan -var-file=environments/staging/terraform.tfvars
terraform apply -var-file=environments/staging/terraform.tfvars
```

### Deploy Production Environment

```bash
# Change to prod workspace
terraform workspace new prod || terraform workspace select prod

# Deploy production (automatically enables Multi-AZ, enhanced backups)
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

## 📊 What Gets Created

### Networking (`modules/networking/`)
- **VPC** - Virtual Private Cloud with custom CIDR
- **Public Subnets** - For load balancer, internet-facing resources
- **Private Subnets** - For EC2, RDS (no direct internet access)
- **Internet Gateway** - Enables outbound internet access
- **NAT Gateway** - Allows private resources outbound internet access
- **Route Tables** - Public (via IGW), Private (via NAT)
- **Security Groups** - Web (HTTP/HTTPS/SSH), Database (PostgreSQL)

### Compute (`modules/compute/`)
- **EC2 Instances** - Amazon Linux 2, auto-configured web servers
- **Launch Template** - Standardized instance configuration
- **IAM Role & Instance Profile** - Permissions for CloudWatch, SSM
- **CloudWatch Log Group** - Application logs centralized
- **User Data Script** - Automatic Nginx setup, health checks

### Database (`modules/database/`)
- **RDS PostgreSQL** - Managed database with automatic backups
- **DB Subnet Group** - Private subnet placement
- **Multi-AZ** - Automatic failover (production only)
- **Encrypted Storage** - AES-256 encryption at rest
- **Enhanced Monitoring** - CPU, memory, I/O metrics
- **Automated Backups** - 7+ days retention
- **Performance Insights** - Query performance analysis
- **CloudWatch Alarms** - High CPU, low storage alerts

### Load Balancer (`modules/load_balancer/`)
- **Application Load Balancer (ALB)** - Distributes traffic to EC2 instances
- **Target Group** - Health checks, load distribution rules
- **Auto Scaling Group** - Automatically scales instances (1-5 based on CPU)
- **Scaling Policies** - Scale up at 70% CPU, scale down at 30%
- **CloudWatch Alarms** - Monitor ALB response time, unhealthy hosts

## 🔧 Configuration Options

### Environment Variables

Edit `environments/{dev|staging|prod}/terraform.tfvars`:

```hcl
environment             = "dev"               # dev, staging, prod
aws_region              = "us-east-1"         # AWS region
aws_instance_count      = 1                   # Number of EC2 instances
aws_instance_type       = "t2.micro"          # Instance size
aws_vpc_cidr            = "10.0.0.0/16"       # VPC IP range
db_instance_class       = "db.t3.micro"       # Database size
db_allocated_storage    = 20                  # Database storage (GB)
```

### Database Credentials

Set sensitive variables via environment or prompt:

```bash
# Option 1: Set via environment variables
export TF_VAR_db_password="your-secure-password-here"
terraform apply -var-file=environments/dev/terraform.tfvars

# Option 2: Terraform will prompt for sensitive variables
terraform apply -var-file=environments/dev/terraform.tfvars
# Enter db_password when prompted
```

## 📡 Accessing Resources

### Get Load Balancer URL

```bash
# After deployment, get the ALB DNS name
terraform output aws_alb_dns_name
# Output: example-alb-12345.us-east-1.elb.amazonaws.com

# Access web application
curl http://<alb-dns-name>
```

### Connect to Database

```bash
# Get database connection details
terraform output aws_db_connection_string

# Example connection string (replace PASSWORD)
postgresql://postgres:PASSWORD@saybaba-infrastructure-db.xxxxx.us-east-1.rds.amazonaws.com:5432/saybaba

# Connect with psql
psql -h saybaba-infrastructure-db.xxxxx.us-east-1.rds.amazonaws.com \
     -U postgres \
     -d saybaba
```

### SSH into EC2 Instances

```bash
# Get instance IPs
terraform output aws_instance_public_ips
# Output: ["54.123.45.67", "54.123.45.68"]

# SSH into instance
ssh -i ~/.ssh/your-key.pem ec2-user@54.123.45.67
```

## 🔒 Security Best Practices

### ✅ Implemented
- **Security Groups** - Restrictive ingress/egress rules
- **Encryption** - RDS storage encrypted at rest
- **IAM Roles** - EC2 instances have minimal permissions
- **Private Subnets** - Database in private subnets, no direct internet
- **CloudWatch Monitoring** - Real-time alerts on suspicious activity
- **Backup Strategy** - Automated daily backups with retention

### 🔐 Recommendations for Production

1. **Restrict SSH Access**
   ```hcl
   allowed_ssh_cidrs = ["203.0.113.0/24"]  # Your IP range only
   ```

2. **Use Remote State Backend**
   ```hcl
   backend "s3" {
     bucket         = "your-terraform-state-bucket"
     key            = "prod/terraform.tfstate"
     region         = "us-east-1"
     encrypt        = true
   }
   ```

3. **Enable VPC Flow Logs**
   ```bash
   # Manual setup in AWS Console or add to main.tf
   ```

4. **Use Secrets Manager for Passwords**
   ```bash
   aws secretsmanager create-secret --name prod/db-password --secret-string <password>
   ```

5. **Enable CloudTrail for Audit Logging**

## 💰 Cost Estimation

### Development
- 1 t2.micro EC2: ~$9/month
- 1 t3.micro RDS: ~$15/month
- NAT Gateway disabled (saves $30/month)
- **Total: ~$24/month**

### Production
- 3 t2.medium EC2: ~$90/month
- 1 t3.medium RDS Multi-AZ: ~$80/month
- NAT Gateway: ~$30/month
- **Total: ~$200/month**

*Prices are approximate and vary by region. Use AWS Pricing Calculator for accurate estimates.*

## 📈 Scaling & Optimization

### Auto-Scaling
The infrastructure automatically scales based on CPU utilization:
- **Scale Up**: When average CPU > 70% for 10 minutes
- **Scale Down**: When average CPU < 30% for 10 minutes
- **Min Instances**: 1 (dev), 2 (staging), 3 (prod)
- **Max Instances**: 3-10 depending on environment

### To Adjust Scaling

Edit the load balancer module variables:
```hcl
min_size                = 1
max_size                = 5
scale_up_threshold      = 70    # CPU percentage
scale_down_threshold    = 30    # CPU percentage
```

## 🔄 State Management

### Local State (Development)
```bash
# States are stored locally in terraform.tfstate
# NOT recommended for team/production
```

### Remote State Backend (Production)
```hcl
# Uncomment in providers.tf and configure:
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "multi-cloud/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"  # Prevents concurrent modifications
}
```

Setup:
```bash
# Create S3 bucket and DynamoDB table manually, then run:
terraform init
# Select "Yes" to migrate to S3 backend
```

## 🧹 Cleanup

### Destroy Development Environment
```bash
terraform destroy -var-file=environments/dev/terraform.tfvars
```

### Destroy All Environments
```bash
# Dev
terraform workspace select dev
terraform destroy -var-file=environments/dev/terraform.tfvars

# Staging
terraform workspace select staging
terraform destroy -var-file=environments/staging/terraform.tfvars

# Prod
terraform workspace select prod
terraform destroy -var-file=environments/prod/terraform.tfvars
```

**⚠️ WARNING**: Destroying will delete all resources including databases. Take backups first!

## 📚 Learning Resources

### Terraform Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language](https://www.terraform.io/language)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/recommended-practices)

### AWS Services Used
- [VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [RDS Documentation](https://docs.aws.amazon.com/rds/)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)

## 🛠️ Troubleshooting

### Common Issues

**Issue**: `Error: error creating VPC: AuthFailure.ServiceUnavailable`
- **Solution**: Check AWS credentials: `aws sts get-caller-identity`

**Issue**: `Error: InvalidParameterValue: The parameter /aws/service/ami-amazon-linux-2/...`
- **Solution**: AMI not available in your region, change `aws_region`

**Issue**: RDS backup space full
- **Solution**: Increase `db_allocated_storage` in tfvars

**Issue**: Load balancer shows unhealthy targets
- **Solution**: Check security group rules allow traffic to port 80

## 📞 Support

For issues:
1. Check Terraform logs: `TF_LOG=DEBUG terraform plan`
2. Check AWS CloudFormation events in AWS Console
3. Review security group rules
4. Verify IAM permissions

## 📝 License

This project is open source and available for educational and commercial use.

---

**Created by**: Olawalebabatunde (Portfolio Project)  
**Last Updated**: June 2026  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: >= 5.0
