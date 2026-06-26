# Terraform Technical Test

## Prerequisites

1. Terraform CLI (>= 1.9.0)
2. Git CLI
3. (Optional, for local checks) `tflint` and `tfsec`/`trivy`

## Instructions

This repository contains a Terraform configuration for a simple web
application. The configuration is **incomplete and contains errors**.

Work on a branch and open a Pull Request that:

1. Ensures the GitHub CI pipeline executes successfully on PRs and merges
2. Fixes any configuration errors identified by the CI pipeline
3. DRYs (Don't Repeat Yourself) the code for **subnet creation** and
   **route table association**

## What will be validated

1. Git experience (amend a commit message, squash and rebase)
2. CI pipeline configuration
3. Terraform linting (variables, formatting)
4. Terraform security misconfiguration
5. Use of `count` vs `for_each`

## Layout

```
.
├── .github/workflows/terraform.yml
├── versions.tf
├── main.tf
├── variables.tf
├── vpc.tf
├── web.tf
├── storage.tf
└── outputs.tf
```

Good luck.
