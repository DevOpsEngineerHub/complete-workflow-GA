
# ==========================================
# AWS PROVIDER
# ==========================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# ==========================================
# DEFAULT VPC
# ==========================================

data "aws_vpc" "default" {
  default = true
}

# ==========================================
# SECURITY GROUP
# ==========================================

resource "aws_security_group" "web_sg" {
  name        = "morning-class-web-sg1"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  # SSH Access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Morning-Class-SG"
  }
}

# ==========================================
# EC2 INSTANCE
# ==========================================

resource "aws_instance" "web" {

  ami           = "ami-0f19324397f53458f"
  instance_type = "t3.micro"

  key_name = "Morning-Class-August"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name        = "Morning-Class-EC2"
    Environment = "Demo"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# OUTPUT - EC2 PUBLIC IP
# ==========================================

output "public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web.public_ip
}

# ==========================================
# OUTPUT - EC2 INSTANCE ID
# ==========================================

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}
