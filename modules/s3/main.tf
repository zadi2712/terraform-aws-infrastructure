/**
 * S3 Module
 * 
 * Creates S3 buckets with security best practices:
 * - Encryption at rest
 * - Versioning
 * - Access logging
 * - Lifecycle policies
 * - Block public access
 * - Bucket policies
 */

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# S3 Bucket
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  
  tags = merge(
    var.tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
    }
  )
}

# Bucket Versioning
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

# Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.kms_key_id != null
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
  
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Logging
resource "aws_s3_bucket_logging" "main" {
  count = var.logging_bucket != null ? 1 : 0
  
  bucket        = aws_s3_bucket.main.id
  target_bucket = var.logging_bucket
  target_prefix = "${var.bucket_name}/"
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id
  
  dynamic "rule" {
    for_each = var.lifecycle_rules
    
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"
      
      filter {
        prefix = lookup(rule.value, "prefix", "")
      }
      
      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      
      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []
        
        content {
          days = rule.value.expiration_days
        }
      }
      
      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration_days", null) != null ? [1] : []
        
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "main" {
  count  = var.bucket_policy != null ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = var.bucket_policy
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "main" {
  count  = length(var.cors_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id
  
  dynamic "cors_rule" {
    for_each = var.cors_rules
    
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", [])
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", [])
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", 3000)
    }
  }
}
