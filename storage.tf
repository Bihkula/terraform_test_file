# S3 bucket for static assets
resource "aws_s3_bucket" "assets" {
  bucket = "${var.project_name}-static-assets"

  tags = {
    Name = "${var.project_name}-static-assets"
  }
}
