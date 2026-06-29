# S3 bucket for static assets
#checkov:skip=CKV2_AWS_62:Event notifications not required
#checkov:skip=CKV2_AWS_61:Lifecycle not required
#checkov:skip=CKV_AWS_144:Cross-region replication not required
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project_name}-static-assets"

  tags = {
    Name = "${var.project_name}-static-assets"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# KMS key for S3 encryption (fixes CKV2_AWS_64 with explicit policy)
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAccountAccess"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::root" }
        Action    = "kms:*"
        Resource  = "*"
      }
    ]
  })
}

# Encryption with CMK
resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Logging
resource "aws_s3_bucket_logging" "assets" {
  bucket        = aws_s3_bucket.assets.id
  target_bucket = aws_s3_bucket.assets.id
  target_prefix = "access-logs/"
}
