# Terraform Technical Test

## Prerequisites

1. Terraform CLI (>= 1.9.0)
2. Git CLI
3. (Optional, for local checks) tflint and tfsec/trivy

## Issues Found and Resolved

### Linting and Validation

- Removed unused variables db_password and enable_logging
- Fixed typo public_subnet_cidr to public_subnet_cidrs
- Fixed 4-space indentation to 2-space in vpc.tf
- Fixed missing closing brace in vpc.tf
- Removed invalid depends_on on variable in web.tf
- Added missing description on instance_type variable

### Security Hardening

- S3: Added public access block, KMS encryption, versioning, logging
- EC2: Enforced IMDSv2, encrypted EBS, enabled monitoring, added IAM role
- VPC: Added flow logs, restricted default security group
- Security Group: Restricted SSH to internal, limited egress to HTTPS only
- CloudWatch: Added KMS encryption, set retention to 365 days
- IAM: Scoped resource from wildcard to specific log group ARN

### DRY Refactor (count to for_each)

- Changed subnet variables from list(string) to map(string)
- Refactored aws_subnet.public and aws_subnet.private to use for_each
- Refactored route table associations to use for_each

### CI/CD Pipeline

- Added .github/workflows/terraform.yml
- Steps: terraform fmt, init, validate, tflint, trivy scan

### Validation Results

- tflint: 0 issues
- terraform fmt: clean
- terraform validate: valid
- trivy: 0 misconfigurations
- checkov: 64 passed, 0 failed
