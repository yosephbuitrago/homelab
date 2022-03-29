output "zome_id" {
  value = aws_route53_zone.primary.id
}

output "zome_arn" {
  value = aws_route53_zone.primary.arn
}

output "zone_name" {
  value = aws_route53_zone.primary.name
}

output "external_dns_key_id" {
  value = aws_iam_access_key.external_dns.id
}

output "external_dns_secret_access_key" {
  value = aws_iam_access_key.external_dns.secret
}

output "cert_manager_key_id" {
  value = aws_iam_access_key.cert_manager.id
}

output "cert_manager_secret_access_key" {
  value = aws_iam_access_key.cert_manager.secret
}