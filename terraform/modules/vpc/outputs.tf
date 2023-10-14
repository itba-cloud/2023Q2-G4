output "vpc_info" {
  value = {
    vpc_id   = aws_vpc.main.id
    vpc_cidr = aws_vpc.main.cidr_block
  }
}

output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}