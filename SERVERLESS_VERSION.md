# 🚀 Serverless Version (AWS Lambda + DynamoDB + API Gateway)

Production-ready serverless infrastructure using AWS Lambda, DynamoDB, and API Gateway.

## Cost Comparison

### Original Architecture (EC2/RDS)
- 1 t2.micro EC2: ~$9/month
- 1 t3.micro RDS: ~$15/month
- ALB: ~$15/month
- **Total: $39/month**

### Serverless Architecture (Lambda/DynamoDB/API Gateway)
- Lambda: **FREE** (1M requests/month included)
- DynamoDB: **FREE** (25GB storage included)
- API Gateway: **FREE** (1M API calls/month included)
- **Total: $0-2/month (stays in free tier!)**

**Savings: ~$37/month or 95% cheaper! 🎉**

---

## Architecture

```
Internet
   ↓
API Gateway (HTTP REST API)
   ↓
Lambda Functions (Serverless compute)
   ↓
DynamoDB (NoSQL database)
   ↓
CloudWatch (Monitoring & Logs)
```

**Benefits:**
✅ Zero servers to manage
✅ Unlimited auto-scaling (no capacity planning)
✅ Pay only for what you use
✅ Automatic backups
✅ Built-in monitoring
✅ Perfect for modern applications

---

## Project Structure

```
Terraform-MultiCloud-Infrastructure/
├── SERVERLESS_main.tf          # Orchestrates serverless modules
├── SERVERLESS_outputs.tf        # Outputs for serverless deployment
├── lambda_function.js           # Sample Lambda function code
├── modules/
│   ├── api/                     # API Gateway module (NEW)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── lambda/                  # Lambda functions module (NEW)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── dynamodb/                # DynamoDB module (NEW)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── networking/              # VPC (optional for Lambda VPC)
├── environments/
│   ├── dev/terraform.tfvars
│   ├── staging/terraform.tfvars
│   └── prod/terraform.tfvars
└── README.md
```

---

## How to Deploy

### Step 1: Replace main.tf
```bash
# Rename original
mv main.tf main.tf.ec2

# Use serverless version
cp SERVERLESS_main.tf main.tf
cp SERVERLESS_outputs.tf outputs.tf
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Plan Deployment
```bash
terraform plan -var-file=environments/dev/terraform.tfvars
```

### Step 4: Deploy
```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

### Step 5: Get Your API Endpoint
```bash
terraform output api_endpoint
# Returns: https://xxxxxx.execute-api.us-east-1.amazonaws.com/dev

# Test the health check endpoint
curl https://xxxxxx.execute-api.us-east-1.amazonaws.com/dev/health
```

---

## What You Get

✅ **REST API Endpoint** - Public HTTPS endpoint for your application
✅ **Lambda Functions** - Serverless compute with automatic scaling
✅ **DynamoDB Table** - Serverless NoSQL database with point-in-time recovery
✅ **API Monitoring** - CloudWatch alarms for errors and latency
✅ **DynamoDB Monitoring** - Alerts for read/write capacity and errors
✅ **Automatic Logging** - All API and Lambda logs in CloudWatch
✅ **Security** - IAM roles with least-privilege access
✅ **Encryption** - DynamoDB encrypted at rest

---

## Example Requests

### Health Check
```bash
curl https://api-endpoint/dev/health

# Response:
{
  "status": "healthy",
  "timestamp": "2026-06-19T12:00:00.000Z",
  "service": "saybaba-serverless-api",
  "environment": "dev",
  "uptime": 3600
}
```

### Create Item
```bash
curl -X POST https://api-endpoint/dev/items \
  -H "Content-Type: application/json" \
  -d '{"name": "My Item", "description": "Test"}'
```

### Get Item
```bash
curl https://api-endpoint/dev/items/USER#123456
```

---

## Scaling Characteristics

| Metric | Limit | Notes |
|--------|-------|-------|
| API Requests | 1M/month FREE | Auto-scales unlimited |
| Lambda Executions | 1M/month FREE | 3.3M requests/day free |
| DynamoDB Storage | 25GB FREE | Auto-scales on demand |
| Concurrent Lambdas | 1000 | Per region, AWS can increase |
| Lambda Timeout | 15 minutes | Max execution time |
| DynamoDB Throughput | Unlimited | No capacity planning needed |

---

## Free Tier Limits (Per Month)

- **API Gateway:** 1,000,000 API calls ✅
- **Lambda:** 1,000,000 free requests + 400,000 GB-seconds ✅
- **DynamoDB:** 25 GB storage + 25 units read + 25 units write ✅

**Most startups fit comfortably in free tier! 🎯**

---

## Monitoring

### View Lambda Logs
```bash
aws logs tail /aws/lambda/saybaba-infrastructure --follow
```

### View API Logs
```bash
aws logs tail /aws/apigateway/saybaba-infrastructure --follow
```

### Check DynamoDB Metrics
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedWriteCapacityUnits \
  --dimensions Name=TableName,Value=saybaba-infrastructure-table \
  --start-time 2026-06-19T00:00:00Z \
  --end-time 2026-06-19T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

---

## Comparison with Original

| Aspect | EC2/RDS | Lambda/DynamoDB |
|--------|---------|-----------------|
| **Cost** | $39/month | FREE |
| **Servers to Manage** | 1 EC2 | 0 |
| **Scaling** | Manual | Automatic |
| **Cold Starts** | None | ~100-300ms (first request) |
| **Max Concurrency** | Based on instance | 1000+ (unlimited) |
| **Data Persistence** | Yes | Yes (DynamoDB) |
| **Monitoring** | CloudWatch | CloudWatch |
| **Learning Curve** | Moderate | Easier |

---

## When to Use Serverless

✅ **Good for:**
- APIs and microservices
- Event-driven applications
- Variable traffic patterns
- Budget-conscious projects
- Rapid prototyping
- Startups

❌ **Maybe not for:**
- Long-running processes (>15min)
- Extremely low latency (<100ms)
- Consistent high throughput
- Complex networking requirements

---

## Estimate vs Reality

If your app gets 100K API calls/month:
- **Lambda cost:** ~$0.00 (still free)
- **API Gateway cost:** ~$0.00 (still free)
- **DynamoDB cost:** ~$0.00 (still free)
- **Total:** **$0.00/month** 🎉

When you hit 10M API calls/month:
- **Lambda:** ~$2
- **API Gateway:** ~$3.50
- **DynamoDB:** ~$1.50 (if needed)
- **Total:** ~$7/month (vs $39 for servers!)

---

## Next Steps

1. ✅ **Deploy serverless version** (5 minutes)
2. ✅ **Test API endpoints** (2 minutes)
3. ✅ **Add Lambda functions** (implement business logic)
4. ✅ **Monitor with CloudWatch** (set up alarms)
5. ✅ **Scale to production** (no changes needed!)

---

## Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [DynamoDB Guide](https://docs.aws.amazon.com/dynamodb/)
- [API Gateway REST API](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html)
- [Serverless Framework](https://www.serverless.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

**Ready to go serverless? Deploy now! 🚀**
