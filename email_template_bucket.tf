

resource "random_id" "bucket_name_id" {
  byte_length = 8
}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  email_templates_bucket_name = lower("${var.environment}-${var.project_name}-email-templates-${random_id.bucket_name_id.dec}")
}
#--------------------------------------------------------------
# S3 bucket
#--------------------------------------------------------------
resource "aws_s3_bucket" "email_templates_bucket" {
  bucket        = local.email_templates_bucket_name
  force_destroy = true

  tags = merge(var.tags, { Name = local.email_templates_bucket_name })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.email_templates_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_side_encryption" {
  bucket = aws_s3_bucket.email_templates_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#--------------------------------------------------------------
# S3 objects
#--------------------------------------------------------------
resource "aws_s3_object" "email_templates_bucket_objects" {
  for_each = fileset("${path.module}/email-templates", "**")

  bucket = aws_s3_bucket.email_templates_bucket.id
  key    = each.value
  source = "${path.module}/email-templates/${each.value}"
  etag   = filemd5("${path.module}/email-templates/${each.value}")
}

output "email_templates_bucket_name_id" {
  value = aws_s3_bucket.email_templates_bucket.id
}