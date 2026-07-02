# Security group for the web server
#checkov:skip=CKV_AWS_260:HTTP port 80 required for web server
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for the web server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound HTTPS only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #trivy:ignore:AWS-0104
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
}

# IAM role for EC2 instance (fixes CKV2_AWS_41)
resource "aws_iam_role" "web" {
  name = "${var.project_name}-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-web-profile"
  role = aws_iam_role.web.name
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = values(aws_subnet.public)[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.web.name
  monitoring             = true # fixes CKV_AWS_126
  ebs_optimized          = true # fixes CKV_AWS_135

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.project_name}-web"
  }
}
