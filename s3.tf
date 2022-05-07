# block public access
resource "aws_s3_bucket_public_access_block" "root_block" {
  bucket = aws_s3_bucket.root_bucket.id

  block_public_acls   = true
  block_public_policy = true

  ignore_public_acls = true
}

resource "aws_s3_bucket_public_access_block" "artifact_block" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls   = true
  block_public_policy = true

  ignore_public_acls = true

  provider = aws.acm_provider
}

# S3 bucket for build artifacts.
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.s3_artifact_bucket
  provider = aws.acm_provider
  tags = var.common_tags
}


resource "aws_s3_bucket_acl" "artifact_bucket_acl" {
  bucket = aws_s3_bucket.artifact_bucket.id
  provider = aws.acm_provider
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id
  provider = aws.acm_provider
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "root_bucket" {
  bucket = var.bucket_name
  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket = aws_s3_bucket.root_bucket.id
  policy = data.aws_iam_policy_document.s3_read_permissions_root.json
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name}"
}

data "aws_iam_policy_document" "s3_read_permissions_root" {
  statement {
    effect = "Allow"

    sid = "PublicReadGetObject"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.root_bucket.arn,
      "${aws_s3_bucket.root_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_acl" "root_bucket_acl" {
  bucket = aws_s3_bucket.root_bucket.id
  acl    = "private"
}

