#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
provider "random" {}

resource "random_id" "bucket_name_id" {
  byte_length = 8
}

locals {
  email_templates_bucket_name = lower("${var.environment}-${var.project_name}-email-templates-${random_id.bucket_name_id.dec}")
}
#--------------------------------------------------------------
# S3 bucket
#--------------------------------------------------------------
resource "aws_s3_bucket" "email_templates_bucket" {
  bucket        = local.email_templates_bucket_name
  force_destroy = true

  acl = "private"

  versioning {
    enabled = true
  }

  tags = merge(var.tags, { Name = local.email_templates_bucket_name })
}
#--------------------------------------------------------------
# S3 objects
#--------------------------------------------------------------
resource "aws_s3_bucket_object" "email_templates_bucket_objects" {
  for_each = fileset("${path.module}/email-templates", "**")

  bucket = aws_s3_bucket.email_templates_bucket.id
  key    = each.value
  source = "${path.module}/email-templates/${each.value}"
  etag    = filemd5("${path.module}/email-templates/${each.value}")
}
