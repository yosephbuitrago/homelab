
module "route53_homelab" {
  source    = "../../modules/route53_homelab"
  zone_name = var.zone_name
  providers = {
    aws = aws.ireland
  }
}