# ============================================================
# TERRAFORM STATE S3 BUCKET
# ============================================================

resource "aws_s3_bucket" "tfstate" {

  bucket = "${local.project_name}-${local.environment}-tfstate-${local.aws_account_id}"

  force_destroy = false

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

# ============================================================
# VERSIONING
# ============================================================

resource "aws_s3_bucket_versioning" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ============================================================
# SERVER-SIDE ENCRYPTION
# ============================================================

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================
# PUBLIC ACCESS BLOCK
# ============================================================

resource "aws_s3_bucket_public_access_block" "tfstate" {

  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================
# DYNAMODB LOCK TABLE
# ============================================================

resource "aws_dynamodb_table" "terraform_locks" {

  name = "${local.project_name}-${local.environment}-locks"

  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}