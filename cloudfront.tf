# Cloudfront distribution for main s3 site.
resource "aws_cloudfront_distribution" "www_s3_distribution" {

  origin {
    domain_name = aws_s3_bucket.root_bucket.bucket_regional_domain_name
    origin_id   = "S3-.${var.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["www.${var.domain_name}"]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = module.redirect_header_lambda.arn
    }

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-.${var.bucket_name}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

      headers = ["Origin", "CloudFront-Forwarded-Proto"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 31536000
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = var.common_tags
}

# Cloudfront S3 for redirect to www.
resource "aws_cloudfront_distribution" "root_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.root_bucket.bucket_regional_domain_name
    origin_id   = "S3-.${var.bucket_name}"


    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = [var.domain_name]

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/404.html"
  }

  default_cache_behavior {

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = module.redirect_header_lambda.arn
    }

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-.${var.bucket_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      headers = ["Origin", "CloudFront-Forwarded-Proto"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = var.common_tags
}


module "redirect_header_lambda" {
  source                  = "./modules/terraform-aws-lambda-at-edge"
  name                    = "redirect-edge"
  description             = "Adds redirection"
  runtime                 = "python3.9"
  lambda_code_source_dir  = "templates/lambda-redirect"
  lambda_code_filename    = "redirect.py"
  s3_artifact_bucket      = [aws_s3_bucket.artifact_bucket]
  handler                 = "redirect.lambda_handler"
}

# Cloudfront S3 for redirect from books
resource "aws_cloudfront_distribution" "books_s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.root_bucket.bucket_regional_domain_name
    origin_id   = "S3-.${var.bucket_name}"


    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = ["books.${var.bucket_name}"]

  default_cache_behavior {

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = module.redirect_header_lambda.arn
    }

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-.${var.bucket_name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      headers = ["Origin", "CloudFront-Forwarded-Proto"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = var.common_tags
}
