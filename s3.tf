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

# S3 bucket for website.
resource "aws_s3_bucket" "www_bucket" {
  bucket = "www.${var.bucket_name}"

  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.s3_read_permissions.json
}

resource "aws_s3_bucket_acl" "web_bucket_acl" {
  bucket = aws_s3_bucket.www_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "cors_setup" {
  bucket = aws_s3_bucket.www_bucket.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_cors_configuration" "cors_setup_books" {
  bucket = aws_s3_bucket.books_bucket.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://books.${var.domain_name}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "bucket_web_config" {
  bucket = aws_s3_bucket.root_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_website_configuration" "www_web_config" {
  bucket = aws_s3_bucket.www_bucket.bucket

  redirect_all_requests_to {
    host_name = "${var.domain_name}"
    protocol = "https"
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

data "aws_iam_policy_document" "s3_read_permissions" {
  statement {
    effect = "Allow"

    sid = "PublicReadGetObject"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.www_bucket.arn,
      "${aws_s3_bucket.www_bucket.arn}/*",
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name}"
}

data "aws_iam_policy_document" "s3_read_permissions_root" {
  statement {
    effect = "Allow"

    sid = "PublicReadGetObject"

    principals {
      identifiers = ["*"]
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
  acl    = "public-read"
}

# S3 bucket for books.
resource "aws_s3_bucket" "books_bucket" {
  bucket = "books.${var.bucket_name}"

  tags = var.common_tags
}

resource "aws_s3_bucket_policy" "books_bucket_policy" {
  bucket = aws_s3_bucket.books_bucket.id
  policy = data.aws_iam_policy_document.s3_read_permissions_books.json
}

resource "aws_s3_bucket_acl" "books_bucket_acl" {
  bucket = aws_s3_bucket.books_bucket.id
  acl    = "public-read"
}

data "aws_iam_policy_document" "s3_read_permissions_books" {
  statement {
    effect = "Allow"

    sid = "PublicReadGetObjectBooks"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.books_bucket.arn,
      "${aws_s3_bucket.books_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "books_web_config" {
  bucket = aws_s3_bucket.books_bucket.bucket

  redirect_all_requests_to {
    host_name = "www.${var.domain_name}/books"
  }
}

