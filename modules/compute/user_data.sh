#!/bin/bash
set -e

# Log output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting EC2 user data script..."

# Update system
yum update -y
yum install -y amazon-cloudwatch-agent nginx curl git

# Start and enable Nginx
systemctl start nginx
systemctl enable nginx

# Create a simple health check page
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Saybaba Multi-Cloud Infrastructure</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background: #f0f0f0; }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .info { background: #e3f2fd; padding: 10px; border-radius: 4px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Terraform Multi-Cloud Infrastructure</h1>
        <p>Successfully deployed with Terraform!</p>

        <div class="info">
            <h3>Instance Metadata</h3>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <p><strong>Instance ID:</strong> $(ec2-metadata --instance-id | cut -d' ' -f2)</p>
            <p><strong>Availability Zone:</strong> $(ec2-metadata --availability-zone | cut -d' ' -f2)</p>
            <p><strong>Region:</strong> $(ec2-metadata --availability-zone | cut -d' ' -f2 | sed 's/[a-z]$//')</p>
        </div>

        <div class="info">
            <h3>Status</h3>
            <p>✅ Web Server Running</p>
            <p>✅ Cloudwatch Monitoring Enabled</p>
            <p>✅ Auto-scaling Ready</p>
        </div>
    </div>
</body>
</html>
EOF

# Create health check endpoint
cat > /usr/share/nginx/html/health.json <<EOF
{
  "status": "healthy",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": "web-server"
}
EOF

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/nginx/access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/nginx/error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          {
            "name": "cpu_usage_idle",
            "rename": "CPU_IDLE",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": [
          {
            "name": "mem_used_percent",
            "rename": "MEM_USED",
            "unit": "Percent"
          }
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

echo "User data script completed successfully!"
