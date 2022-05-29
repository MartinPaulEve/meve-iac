output "primary_nameservers" {
  description = "The nameservers of the primary domain"
  value = aws_route53_zone.main.name_servers
}

output "secondary_nameservers" {
  description = "The nameservers of the secondary domain"
  value = aws_route53_zone.secondary.name_servers
}
