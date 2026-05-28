output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "cloudwan_subnet_ids" {
  value = aws_subnet.cloudwan[*].id
}

output "cloudwan_subnet_arns" {
  value = aws_subnet.cloudwan[*].arn
}

output "firewall_subnet_ids" {
  value = aws_subnet.firewall[*].id
}

output "firewall_route_table_ids" {
  value = aws_route_table.firewall[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "firewall_arn" {
  value = var.enable_network_firewall ? aws_networkfirewall_firewall.this[0].arn : null
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.this[*].id
}

output "summary" {
  value = {
    vpc_id                = aws_vpc.this.id
    vpc_arn               = aws_vpc.this.arn
    cidr_block            = aws_vpc.this.cidr_block
    cloudwan_subnet_ids   = aws_subnet.cloudwan[*].id
    firewall_subnet_ids   = aws_subnet.firewall[*].id
    public_subnet_ids     = aws_subnet.public[*].id
    firewall_arn          = var.enable_network_firewall ? aws_networkfirewall_firewall.this[0].arn : null
    firewall_flow_log     = var.enable_network_firewall ? aws_cloudwatch_log_group.firewall_flow[0].name : null
    firewall_alert_log    = var.enable_network_firewall ? aws_cloudwatch_log_group.firewall_alert[0].name : null
    nat_gateway_ids       = aws_nat_gateway.this[*].id
    cloudwan_route_tables = aws_route_table.cloudwan[*].id
    firewall_route_tables = aws_route_table.firewall[*].id
    public_route_tables   = aws_route_table.public[*].id
  }
}
