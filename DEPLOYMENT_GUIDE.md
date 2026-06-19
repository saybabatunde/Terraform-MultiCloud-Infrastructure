# 📋 Deployment Guide - Terraform Multi-Cloud Infrastructure

## 🎯 Step-by-Step Deployment Instructions

This guide walks you through deploying the infrastructure to AWS across different environments.

---

## Phase 1: Prerequisites & Setup

### 1.1 Install Required Tools

```bash
# Terraform (required)
brew install terraform          # macOS
choco install terraform         # Windows
apt-get install terraform       # Linux (Ubuntu/Debian)

# AWS CLI (optional but recommended)
brew install awscli             # macOS
choco install awscliv2          # Windows
pip install awscli              # Linux

# Verify installations
terraform version               # Should show v1.0 or higher
aws --version                   # Should show v2.0 or higher
```

### 1.2 Configure AWS Credentials

```bash
# Interactive setup
aws configure

# You'll be prompted for:
# AWS Access Key ID: [enter your key]
# AWS Secret Access Key: [enter your secret]
# Default region name: us-east-1
# Default output format: json

# Verify credentials work
aws sts get-caller-identity
# Output should show your AWS account details
```

### 1.3 Clone/Setup Project

```bash
# If on GitHub
git clone <your-repo-url>
cd Terraform-MultiCloud-Infrastructure

# Or create locally
terraform init
```

---

## Phase 2: Development Environment Deployment

### 2.1 Review Development Configuration

```bash
# Check what will be deployed
cat environments/dev/terraform.tfvars

# Should show:
# - 1 t2.micro EC2 instance (small, cheap)
# - 1 t3.micro RDS database
# - No NAT Gateway (save costs)
```

### 2.2 Plan the Deployment

```bash
# See exactly what Terraform will create (NO changes made yet)
terraform plan -var-file=environments/dev/terraform.tfvars

# Review the output - should show:
# Plan: XX to add, 0 to change, 0 to destroy
# This is your opportunity to verify before applying
```

### 2.3 Deploy to Development

```bash
# Apply the plan (creates actual AWS resources)
terraform apply -var-file=environments/dev/terraform.tfvars

# When prompted, review the summary and type: yes

# Wait for deployment (5-15 minutes)
# Terraform will show:
# Apply complete! Resources: XX added, 0 changed, 0 destroyed

# View outputs (copy the ALB URL)
terraform output
```

### 2.4 Verify Development Deployment

```bash
# Get the load balancer URL
ALB_URL=$(terraform output -raw aws_alb_dns_name)

# Test the web application
curl http://${ALB_URL}

# You should see the HTML page with server details

# Check EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,State.Name]' --output table

# Check RDS database
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' --output table
```

### 2.5 Access Development Resources

```bash
# SSH into EC2 instance
PUBLIC_IP=$(terraform output -raw aws_instance_public_ips | jq -r '.[0]')
ssh -i ~/.ssh/your-aws-key.pem ec2-user@${PUBLIC_IP}

# Connect to database
DB_ENDPOINT=$(terraform output -raw aws_db_host)
psql -h ${DB_ENDPOINT} -U postgres -d saybaba
# Enter password when prompted

# View CloudWatch logs
aws logs tail /aws/saybaba-infrastructure/application --follow
```

---

## Phase 3: Staging Environment Deployment

### 3.1 Create Staging Workspace

```bash
# Workspaces keep state separated
terraform workspace new staging
# or
terraform workspace select staging

# Verify you're in staging
terraform workspace show
# Output: staging
```

### 3.2 Review Staging Configuration

```bash
# Check staging specs (larger than dev, production-like)
cat environments/staging/terraform.tfvars

# Should show:
# - 2 t2.small EC2 instances
# - 1 t3.small RDS database (Multi-AZ)
# - NAT Gateway enabled
# Total cost ~$60-70/month
```

### 3.3 Deploy Staging

```bash
# Plan
terraform plan -var-file=environments/staging/terraform.tfvars

# Apply
terraform apply -var-file=environments/staging/terraform.tfvars

# Verify
terraform output aws_alb_dns_name
curl http://<staging-alb-url>
```

---

## Phase 4: Production Environment Deployment

### 4.1 ⚠️ Pre-Production Checklist

```bash
# BEFORE deploying to production, verify:

# ✅ Development is working
terraform workspace select dev
terraform show

# ✅ Staging is stable (was running for days without issues)
terraform workspace select staging
terraform show

# ✅ Database backup strategy is set
# Review: environments/prod/terraform.tfvars
# Check: backup_retention_period = 30 (days)

# ✅ Monitoring is configured
aws cloudwatch describe-alarms --query 'MetricAlarms[*].AlarmName'

# ✅ Security groups are restricted
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupName,IpPermissions]'
```

### 4.2 Create Production Workspace

```bash
terraform workspace new prod
terraform workspace select prod

# Verify
terraform workspace show
# Output: prod
```

### 4.3 Review Production Configuration

```bash
cat environments/prod/terraform.tfvars

# Should show:
# - 3 t2.medium EC2 instances (HA)
# - 1 t3.medium RDS Multi-AZ
# - NAT Gateway enabled
# - Enhanced monitoring & backups
# Total cost ~$200-250/month
```

### 4.4 Deploy Production

```bash
# Plan with extra confirmation
terraform plan -var-file=environments/prod/terraform.tfvars -out=tfplan

# Review the plan VERY carefully
less tfplan

# Apply
terraform apply tfplan

# This will:
# - Create 3 EC2 instances across AZs
# - Create Multi-AZ RDS database
# - Setup load balancer with auto-scaling
# Wait 10-15 minutes...

# Verify all resources are healthy
aws elb describe-instance-health --load-balancer-name $(terraform output -raw aws_alb_dns_name | cut -d. -f1)
```

### 4.5 Production Validation

```bash
# Get production URL
PROD_URL=$(terraform output -raw aws_application_url)

# Test from multiple angles
curl -v http://${PROD_URL}              # Basic connectivity
curl -H "User-Agent: Production Check" http://${PROD_URL}/health.json
ab -n 100 -c 10 http://${PROD_URL}/    # Load testing

# Check database replication (Multi-AZ)
aws rds describe-db-instances \
  --db-instance-identifier saybaba-infrastructure-db \
  --query 'DBInstances[0].[MultiAZ,PendingModifiedValues]'

# Monitor auto-scaling
aws autoscaling describe-auto-scaling-groups \
  --query 'AutoScalingGroups[*].[AutoScalingGroupName,DesiredCapacity,RunningInstances]'
```

---

## Phase 5: Post-Deployment Monitoring & Maintenance

### 5.1 Setup CloudWatch Dashboard

```bash
# Create simple CloudWatch dashboard (manual in AWS Console):
# 1. CloudWatch → Dashboards → Create Dashboard
# 2. Add widgets:
#    - ALB Request Count
#    - ALB Response Time
#    - EC2 CPU Utilization
#    - RDS CPU/Memory
#    - RDS Free Storage Space
```

### 5.2 Monitoring Commands

```bash
# Get current metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Watch ALB health
watch -n 5 'aws elb describe-instance-health --load-balancer-name $(terraform output -raw aws_alb_dns_name | cut -d. -f1)'

# Monitor RDS backup progress
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,BackupRetentionPeriod,LatestRestorableTime]'
```

### 5.3 Set SNS Alerts (Optional)

```bash
# Create SNS topic for alarms
aws sns create-topic --name production-alerts

# Get the topic ARN
TOPIC_ARN=$(aws sns list-topics --query 'Topics[0].TopicArn' --output text)

# Subscribe to alerts
aws sns subscribe --topic-arn ${TOPIC_ARN} --protocol email --notification-endpoint your-email@example.com

# Confirm subscription in your email inbox
```

---

## Phase 6: Updates & Scaling

### 6.1 Update Instance Type

```bash
# Change instance type in environment tfvars
# environments/prod/terraform.tfvars
# aws_instance_type = "t2.large"  (was t2.medium)

# Plan
terraform plan -var-file=environments/prod/terraform.tfvars

# Apply (instances will be replaced)
terraform apply -var-file=environments/prod/terraform.tfvars
```

### 6.2 Scale Up Instances

```bash
# Increase instance count
# environments/prod/terraform.tfvars
# aws_instance_count = 5  (was 3)

# Apply (new instances will be added)
terraform apply -var-file=environments/prod/terraform.tfvars
```

### 6.3 Upgrade Database

```bash
# Change DB instance class
# environments/prod/terraform.tfvars
# db_instance_class = "db.t3.large"  (was db.t3.medium)

# Plan (will cause some downtime)
terraform plan -var-file=environments/prod/terraform.tfvars

# Schedule maintenance window first
aws rds modify-db-instance \
  --db-instance-identifier saybaba-infrastructure-db \
  --preferred-maintenance-window "sun:03:00-sun:04:00" \
  --apply-immediately

# Apply during maintenance window
terraform apply -var-file=environments/prod/terraform.tfvars
```

---

## Phase 7: Disaster Recovery & Backups

### 7.1 Create Manual Snapshot

```bash
# Snapshot RDS database
aws rds create-db-snapshot \
  --db-instance-identifier saybaba-infrastructure-db \
  --db-snapshot-identifier manual-backup-$(date +%Y%m%d-%H%M%S)

# Snapshot completed when Status = available
aws rds describe-db-snapshots \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,SnapshotCreateTime,Status]'
```

### 7.2 Test Restore

```bash
# Restore from snapshot (creates new DB instance)
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier saybaba-infrastructure-db-restore-test \
  --db-snapshot-identifier manual-backup-20260619-120000

# Clean up test instance when done
aws rds delete-db-instance \
  --db-instance-identifier saybaba-infrastructure-db-restore-test \
  --skip-final-snapshot
```

### 7.3 Enable Automated Backups (Already Configured)

```bash
# Verify backup retention
aws rds describe-db-instances \
  --query 'DBInstances[0].BackupRetentionPeriod'
# Should show: 30 (production) or 7 (dev/staging)

# Backups are automatic and retained
# To restore: Use AWS Console or CLI
```

---

## Phase 8: Cleanup & Destruction

### 8.1 Destroy Development (When Done)

```bash
terraform workspace select dev

# Plan destruction
terraform plan -destroy -var-file=environments/dev/terraform.tfvars

# Destroy
terraform destroy -var-file=environments/dev/terraform.tfvars
# Type 'yes' when prompted

# Verify resources are gone
aws ec2 describe-instances
```

### 8.2 Destroy All Environments

```bash
# Dev
terraform workspace select dev
terraform destroy -var-file=environments/dev/terraform.tfvars

# Staging
terraform workspace select staging
terraform destroy -var-file=environments/staging/terraform.tfvars

# Prod (CAREFUL!)
terraform workspace select prod
terraform destroy -var-file=environments/prod/terraform.tfvars
```

---

## Troubleshooting

### Issue: "AuthFailure: The security token included in the request is invalid"
```bash
# AWS credentials are not configured correctly
aws configure
# Re-enter your Access Key ID and Secret Access Key
```

### Issue: "InvalidParameterValue: The parameter DBSubnetGroupName cannot be empty"
```bash
# Ensure private subnets were created
terraform output aws_private_subnet_ids
# If empty, private subnets failed to create

# Check VPC
terraform output aws_vpc_id
```

### Issue: "Unhealthy targets detected"
```bash
# Check security group allows traffic
aws ec2 describe-security-groups --group-ids $(terraform output -raw aws_web_security_group_id)

# Check instance logs
aws ssm start-session --target $(terraform output -raw aws_instance_ids | jq -r '.[0]')
tail -f /var/log/user-data.log
```

### Issue: "Load Balancer target response time is high"
```bash
# Check EC2 CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average

# If high, auto-scaling should trigger
# If not, check ASG status
aws autoscaling describe-auto-scaling-groups
```

---

## Summary

You now have a **production-ready multi-cloud infrastructure** managed entirely with Terraform!

**What you've deployed:**
- ✅ VPC with public/private subnets
- ✅ EC2 instances with auto-scaling
- ✅ Application Load Balancer
- ✅ RDS PostgreSQL database (Multi-AZ in prod)
- ✅ CloudWatch monitoring & alarms
- ✅ Automated backups
- ✅ Security groups & IAM roles

**Next steps:**
1. Monitor the dashboards daily
2. Review CloudWatch alarms weekly
3. Test disaster recovery monthly
4. Update security groups as needed
5. Scale instances based on demand

Good luck! 🚀
