variable "domain_name" {
  type        = string
  description = "The domain name for the website."
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "common_tags" {
  description = "Common tags you want applied to all components."
}

variable "s3_artifact_bucket" {
  type        = string
  description = "The artifact bucket name"
}

variable "secondary_domain_name" {
  type        = string
  description = "The secondary domain name for the website."
}