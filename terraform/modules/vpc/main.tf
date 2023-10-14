resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.subnet_configs)

  cidr_block              = cidrsubnet(var.base_cidr_block, var.subnet_configs[count.index].subnet_bits, count.index + 1)
  availability_zone       = var.subnet_configs[count.index].availability_zone
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true # TODO: Revisar

  tags = {
    Name        = var.subnet_configs[count.index].name
    Environment = "Development"
  }
}