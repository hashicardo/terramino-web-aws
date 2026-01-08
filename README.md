# Terramino Web AWS

A simple Terraform module that deploys the Terramino web game to AWS S3 as a static website.

> ⚠️ **Demo purposes only** - This module is for demonstration and learning purposes.

## Quick Start

```bash
git clone https://github.com/hashicardo/terramino-web-aws.git
cd terramino-web-aws
terraform init
terraform apply
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `prefix` | Common prefix for names | `terramino` |
| `aws_region` | AWS Region to deploy the resources | `us-east-1` |
| `debug_message` | Debug message to display in the web application | `Custom message!` |

## Outputs

| Name | Description |
|------|-------------|
| `website_url` | URL of the S3 static website |
| `bucket_name` | Name of the S3 bucket |
| `region` | AWS region where the bucket is deployed |
