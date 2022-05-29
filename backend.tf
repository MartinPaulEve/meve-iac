provider "aws" {
  alias  = "replica"
  region = "eu-west-2"
}

module "remote_state" {
  source = "registry.terraform.io/nozaq/remote-state-s3-backend/aws"
  version = "1.2.0"

  override_s3_bucket_name = true
  s3_bucket_name = "state-${var.bucket_name}"
  dynamodb_table_name = "lock-${var.bucket_name}"

  noncurrent_version_transitions = []
  noncurrent_version_expiration = {
    days = 90
  }

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

