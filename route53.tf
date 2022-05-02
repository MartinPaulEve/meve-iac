# Route 53 for domain
resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = var.common_tags
}

resource "aws_route53_record" "root-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.root_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.root_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-a" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www_s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.www_s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "network" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "network.${var.domain_name}"
  type    = "A"
  ttl     = "300"

  records = [
    "178.128.44.68",
  ]

}

resource "aws_route53_record" "mx" {
  name    = ""
  type    = "MX"
  zone_id = aws_route53_zone.main.zone_id
  ttl     = "300"
  records = [
    "10 mail.protonmail.ch",
    "20 mailsec.protonmail.ch"
  ]
}

# protonmail verify
resource "aws_route53_record" "protonmail_verify" {
  zone_id = aws_route53_zone.main.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "300"

  records = [
    "protonmail-verification=d1ca3d946b08e391477f74817ccb0820888b7db5",
    "v=spf1 include:_spf.protonmail.ch mx ~all"
  ]
}

# acme challenge for CertBot
resource "aws_route53_record" "certbot" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_acme-challenge.network"
  type    = "TXT"
  ttl     = "300"

  records = ["vs-tldWgoZmCBR4HITKJ5rs9DPSYyEYl8O4EIATdbRY"]
}

# protonmail DMARC
resource "aws_route53_record" "protonmail_dmarc" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = "300"

  records = ["v=DMARC1; p=none; rua=mailto:martin@eve.gd"]
}

# protonmail DKIM
resource "aws_route53_record" "DKIM-1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "protonmail._domainkey"
  type    = "CNAME"
  ttl     = "5"

  records = ["protonmail.domainkey.dxyu4qyjbj6hcveupllbb7t57uea3c3fmuceq2x7zwb4gfzz6dszq.domains.proton.ch."]
}

resource "aws_route53_record" "DKIM-2" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "protonmail2._domainkey"
  type    = "CNAME"
  ttl     = "5"

  records = [
    "protonmail2.domainkey.dxyu4qyjbj6hcveupllbb7t57uea3c3fmuceq2x7zwb4gfzz6dszq.domains.proton.ch."
  ]
}

resource "aws_route53_record" "DKIM-3" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "protonmail3._domainkey"
  type    = "CNAME"
  ttl     = "5"

  records = [
    "protonmail3.domainkey.dxyu4qyjbj6hcveupllbb7t57uea3c3fmuceq2x7zwb4gfzz6dszq.domains.proton.ch."
  ]
}


# redirect books to root
#resource "aws_route53_record" "books-alias" {
#  zone_id = aws_route53_zone.main.zone_id
#  name    = "books"
#  type    = "CNAME"
#  ttl     = "5"

#  records = [var.domain_name]
#}

# Uncomment the below block if you are doing certificate validation using DNS instead of Email.
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.main.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_route53_record" "redirect-www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "books.${var.domain_name}"
  type    = "CNAME"
  ttl     = "300"

  records = ["${var.domain_name}"]
}

