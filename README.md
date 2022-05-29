# Infrastructure as Code for eve.gd
This repository contains the terraform files to provision my [personal website](https://eve.gd).

![Martin Paul Eve](https://eve.gd/images/header_new.jpg)

![license](https://img.shields.io/github/license/martinpauleve/meve-iac) ![activity](https://img.shields.io/github/last-commit/MartinPaulEve/meve-iac) 

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white) ![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white) ![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black) ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) 


# Features
* Static serving from an S3 bucket
* Certificate management
* Enforced SSL redirection
* Cloudfront distribution for CDN/acceleration and SSL
* Redirection handled by Lambda@Edge Python
* Canonical redirects from www to bare domain
* Domain-based to path-based redirects (e.g. books.eve.gd -> eve.gd/books/)
* Second domain (martineve.com) also under management
* S3 backend with KMS encryption and replication

# Intended Infrastructure
<img src="docs/resource_map.png?raw=true" alt="Infrastructure resource map"/>

# Setup and Running
First, edit terraform.tfvars to contain the necessary information:

    domain_name = "eve.gd"
    secondary_domain_name = "martineve.com"
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

Edit main.tf temporarily to remove the S3 backend configuration so that you can create the infrastructure first. You can re-insert this to use the remote backend after the first run. This is to handle the [chicken-and-egg problem of state management](https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa).

Then:

    terraform init
    terraform apply

# Details

## Certificates
This setup configures SSL certificates using AWS Certificate Manager. It uses DNS-based validation to authenticate the certificates. This can require a manual intervention the first time it's setup.

## S3 / Storage
This setup creates two S3 buckets:

* The site itself (root_bucket)
* The artifact bucket (artifact_bucket) for Lambda@Edge function builds

## DNS / Route 53
The Route 53 configuration is designed for my Protonmail setup and contains MX, DMARC, and SPF records to allow this. A "gotcha" when spinning up fresh infrastructure is that you need to update the nameservers on the domain, even if the domain is registered with Route 53. It might be possible to update these automatically.

## Cloudfront Distributions
There are three Cloudfront distributions, only one of which will ever see serious traffic:

* The main site
* The www redirect
* the books redirect

## Lambda@Edge Redirection
Redirection is handled by a Lambda@Edge function tied to the "origin-request". This means that redirects are cached (whereas "viewer-request" is executed every time.) It is possible to define a redirect-to-https block in Cloudfront but we can also get this control in the Lambda function, which will run anyway.

# Future Improvements
A core improvement that's not currently in place would be to replicate the S3 buckets to different regions/availability zones and then implement Cloudfront failover to an S3 group. 

# Credits / Third-Party Software

* [Terraform](https://www.terraform.io/) by Hashicorp.
* Modified version of [terraform-aws-lambda-at-edge](https://github.com/transcend-io/terraform-aws-lambda-at-edge) by benjamint-bsquare. The modifications force the Lambda function into the us-east-1 region as this is obligatory for Cloudfront Lamda@Edge functions.
* [Git](https://git-scm.com/) from Linus Torvalds _et al_.
* [.gitignore](https://github.com/github/gitignore) from Github.
* The headshot photograph is courtesy of [Lianne de Mello](https://twitter.com/liannedemello).
* The infrastructure diagram was created with [CloudCraft](https://app.cloudcraft.co/).

&copy; [Martin Paul Eve](mailto:martin@eve.gd), 2022. Released under the terms of [the MIT License](LICENSE).