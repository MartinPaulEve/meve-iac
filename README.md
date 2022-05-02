# Infrastructure as Code for eve.gd
This repository contains the terraform files to provision my [personal website](https://eve.gd).

![Martin Paul Eve](https://eve.gd/images/header_new.jpg)

![license](https://img.shields.io/github/license/martinpauleve/meve-iac)

## Features
* Static serving from an S3 bucket
* Certificate management
* Enforced SSL redirection
* Cloudfront distribution for CDN/acceleration and SSL
* Redirection handled by Lambda@Edge Python
* Canonical redirects from www to bare domain
* Domain-based to path-based redirects (e.g. books.eve.gd -> eve.gd/books/)

## Setup and Running
First, edit terraform.tfvars to contain the necessary information:

    domain_name = "eve.gd"
    bucket_name = "eve.gd"
    
    common_tags = {
      Project = "eve-gd"
    }
    
    s3_artifact_bucket = "artifacts.eve.gd"

Also, modify templates/lambda-redirect/redirect.py and change the domain and redirects as needed.

If using this on another domain, you'll need extensively to customize the route53.tf file, which sets up the DNS nameserver records.

Next, ensure that your .aws folder in your home directory has a working configuration.

~/.aws/config:

    [default]
    region=us-west-2
    output=json

~/.aws/credentials:

    [default]
    aws_access_key_id=YOUR_ACCESS_KEY_HERE
    aws_secret_access_key=YOUR_SECRET_KEY_HERE

Alternatively, you can export these as environment variables.

Then:

    terraform init
    terraform apply

## Certificates
This setup configures SSL certificates using AWS Certificate Manager. It uses DNS-based validation to authenticate the certificates. This can require a manual intervention the first time it's setup.

## S3 / Storage
This setup creates four S3 buckets:

* The site itself (root_bucket)
* The www subdomain redirect (www_bucket)
* The books subdomain redirect (books_bucket)
* The artifact bucket (artifact_bucket) for Lambda@Edge function builds

Future versions could remove the dependence on the www and books buckets as this can be handled by the Lambda@Edge function.

## DNS / Route 53
The Route 53 configuration is designed for my Protonmail setup and contains MX, DMARC, and SPF records to allow this. A "gotcha" when spinning up fresh infrastructure is that you need to update the nameservers on the domain, even if the domain is registered with Route 53. It might be possible to update these automatically.

## Cloudfront Distributions
There are three Cloudfront distributions, only one of which will ever see serious traffic:

* The main site
* The www redirect
* the books redirect

## Credits / Third-Party Software

* [Terraform](https://www.terraform.io/) by Hashicorp
* Modified version of [terraform-aws-lambda-at-edge](https://github.com/transcend-io/terraform-aws-lambda-at-edge) by benjamint-bsquare. The modifications force the Lambda function into the us-east-1 region as this is obligatory for Cloudfront Lamda@Edge functions.
* [.gitignore](https://github.com/github/gitignore) from Github

&copy; Martin Paul Eve, 2022. Released under the terms of [the MIT License](LICENSE).