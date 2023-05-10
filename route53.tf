# Data Sources
data "aws_route53_zone" "zone" {
  zone_id = var.route_53_hosted_zone_id
}

locals {
  dns_name = "${var.app_name}.${data.aws_route53_zone.zone.name}"
}

resource "aws_route53_record" "dns" {
  zone_id = var.route_53_hosted_zone_id
  name    = local.dns_name
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = false
  }
}