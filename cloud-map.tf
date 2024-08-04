resource "aws_service_discovery_private_dns_namespace" "default" {
  count = var.service_connect_configuration != null ? (var.service_connect_configuration.vpc_id != null ? 1 : 0) : 0
  name        = var.service_connect_configuration.namespace
  description = var.service_connect_configuration.description
  vpc         = var.service_connect_configuration.vpc_id
  tags = merge(
    var.tags,
    {
      Name = "${var.service_connect_configuration.namespace}-private_namespace"
    }
  )
}

resource "aws_service_discovery_public_dns_namespace" "example" {
  count = var.service_connect_configuration != null ? (var.service_connect_configuration.vpc_id == null ? 1 : 0) : 0
  name        = var.service_connect_configuration.namespace
  description =var.service_connect_configuration.description
  tags = merge(
    var.tags,
    {
      Name = "${var.service_connect_configuration.namespace}-public_namespace"
    }
  )
}