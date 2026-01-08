terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
      configuration_aliases = [ aws.ue1, aws.ue2, aws.ew1, aws.ew2, aws.uw1]
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}

# Generate a random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = "${var.prefix}-web-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.prefix}-web"
    Environment = "demo"
  }
}

# Configure S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Make bucket public
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

# Upload index.html (with template processing)
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content      = templatefile("${path.module}/web/index.html", {
                    debug_message = var.debug_message, 
                    region_name = data.aws_region.current.region 
                })

  content_type = "text/html"
  etag         = filemd5("${path.module}/web/index.html")
}

# Upload CSS file
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.website.id
  key          = "terramino.css"
  source       = "${path.module}/web/terramino.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/web/terramino.css")
}

# Upload JS file
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.website.id
  key          = "terramino.js"
  source       = "${path.module}/web/terramino.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/web/terramino.js")
}

# Upload any image files if they exist
resource "aws_s3_object" "images" {
  for_each = fileset("${path.module}/web", "*.{png,jpg,jpeg,gif,svg,ico}")

  bucket       = aws_s3_bucket.website.id
  key          = each.value
  source       = "${path.module}/web/${each.value}"
  content_type = lookup(
    {
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "jpeg" = "image/jpeg"
      "gif"  = "image/gif"
      "svg"  = "image/svg+xml"
      "ico"  = "image/x-icon"
    },
    regex("\\.(\\w+)$", each.value)[0],
    "application/octet-stream"
  )
  etag = filemd5("${path.module}/web/${each.value}")
}
