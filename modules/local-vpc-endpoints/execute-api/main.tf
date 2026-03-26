data "aws_region" "current" {}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch subnets dynamically
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_names)

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

locals {
  subnet_ids = [for s in data.aws_subnet.selected : s.id]

  service_name = "com.amazonaws.${data.aws_region.current.name}.${var.endpoint_service}"

  # Default allow-all policy (same as AWS default)
  default_endpoint_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })
}

# Security Group
resource "aws_security_group" "vpce" {
  name        = var.security_group_name
  description = "Security group for ${var.endpoint_name} VPC endpoint"
  vpc_id      = data.aws_vpc.selected.id

  tags = merge(var.tags, {
    Name = var.security_group_name
  })
}

# Ingress rules (dynamic)
resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = {
    for idx, rule in var.ingress_rules : idx => rule
  }

  security_group_id = aws_security_group.vpce.id
  description       = each.value.description
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value.cidr
}

# Egress rule
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.vpce.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow all outbound traffic"
}

# VPC Endpoint
resource "aws_vpc_endpoint" "this" {
  vpc_id              = data.aws_vpc.selected.id
  service_name        = local.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = var.private_dns_enabled

  # Use custom policy if provided, otherwise default
  policy = var.endpoint_policy != null ? var.endpoint_policy : local.default_endpoint_policy

  tags = merge(var.tags, {
    Name = var.endpoint_name
  })
}