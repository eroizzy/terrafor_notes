data "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
