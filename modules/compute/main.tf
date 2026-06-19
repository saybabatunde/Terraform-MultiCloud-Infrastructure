# Compute Module - EC2 Instances

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for web server setup
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    app_port = var.app_port
  }))
}

# Launch Template for EC2 instances
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.security_group_id]

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.project_name}-web-server"
      }
    )
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

# EC2 Instances
resource "aws_instance" "web" {
  count            = var.instance_count
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-web-${count.index + 1}"
    }
  )

  depends_on = [aws_iam_role_policy.ec2_policy]
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Role Policy for EC2 (CloudWatch, SSM)
resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:AcknowledgeMessage",
          "ssmmessages:GetEndpoint",
          "ssmmessages:GetMessages",
          "ec2messages:GetMessages"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
