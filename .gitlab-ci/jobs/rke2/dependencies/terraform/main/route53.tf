resource "aws_route53_zone" "docker" {
  count = var.airgap == false  ? 0 : 1
  name = "docker.io"

  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
  depends_on = [module.rke2]
  tags = local.tags
}

resource "aws_route53_record" "docker_registry" {
  count = var.airgap == false  ? 0 : 1
  zone_id = aws_route53_zone.docker.zone_id
  name    = "docker.io"
  type    = "A"
  ttl     = "300"
  records = [var.utility_ip]
}