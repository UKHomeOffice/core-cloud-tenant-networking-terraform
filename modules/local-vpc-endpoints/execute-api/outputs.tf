output "vpc_endpoint_id" {
  value = aws_vpc_endpoint.this.id
}

output "vpc_endpoint_dns_entries" {
  value = aws_vpc_endpoint.this.dns_entry
}

output "security_group_id" {
  value = aws_security_group.vpce.id
}

output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "subnet_ids" {
  value = local.subnet_ids
}