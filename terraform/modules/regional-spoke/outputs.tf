output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  value = aws_subnet.private[*].arn
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "security_group_id" {
  value = aws_security_group.workload.id
}

output "summary" {
  value = {
    vpc_id                   = aws_vpc.this.id
    vpc_arn                  = aws_vpc.this.arn
    cidr_block               = aws_vpc.this.cidr_block
    private_subnet_ids       = aws_subnet.private[*].id
    private_route_table_id   = aws_route_table.private.id
    test_instance_id         = var.enable_test_instance ? aws_instance.test[0].id : null
    test_instance_private_ip = var.enable_test_instance ? aws_instance.test[0].private_ip : null
  }
}

output "test_instance" {
  value = var.enable_test_instance ? {
    id         = aws_instance.test[0].id
    private_ip = aws_instance.test[0].private_ip
    subnet_id  = aws_instance.test[0].subnet_id
  } : null
}
