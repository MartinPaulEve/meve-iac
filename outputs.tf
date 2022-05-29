output "primary_nameservers" {
  description = "The nameservers of the primary domain"
  value = aws_route53_zone.main.name_servers
}

output "secondary_nameservers" {
  description = "The nameservers of the secondary domain"
  value = aws_route53_zone.secondary.name_servers
}

output "state_bucket" {
  description = "The state bucket that has been used"
  value = module.remote_state.state_bucket.bucket
}

output "state_bucket_kms_id" {
  description = "The encryption ID for the state bucket"
  value = module.remote_state.kms_key.arn
}

output "state_dynamo_db" {
  description = "The DynamoDB table used for locking"
  value = module.remote_state.dynamodb_table.name
}
