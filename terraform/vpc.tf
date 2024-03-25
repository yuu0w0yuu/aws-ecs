### VPC
resource "aws_vpc" "main_vpc" {

  cidr_block = local.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.prefix}-vpc"
  }
}

### Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id   = aws_vpc.main_vpc.id
  for_each = { for i in local.public_subnets : i.az => i }

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.prefix}-public-${each.value.az}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id   = aws_vpc.main_vpc.id
  for_each = { for i in local.private_subnets : i.az => i }

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.prefix}-private-${each.value.az}"
  }
}

### Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${local.prefix}-internet-gateway"
  }
}

resource "aws_eip" "eip_natgateway" {
  domain = "vpc"
  tags = {
    Name = "${local.prefix}-eip-natgateway"
  }
}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.eip_natgateway.id
  subnet_id     = aws_subnet.public_subnet["ap-northeast-1a"].id
  tags = {
    Name = "${local.prefix}-natgateway"
  }
}

### Route Table
resource "aws_route_table" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${local.prefix}-rtb-internet-gateway"
  }
}

resource "aws_route_table_association" "internet_gateway" {
  for_each       = { for i in local.public_subnets : i.az => i }
  route_table_id = aws_route_table.internet_gateway.id
  subnet_id      = aws_subnet.public_subnet[each.value.az].id
}

resource "aws_route_table" "natgateway" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgateway.id
  }
  tags = {
    Name = "${local.prefix}-rtb-natgateway"
  }
}

resource "aws_route_table_association" "natgateway" {
  for_each       = { for i in local.private_subnets : i.az => i }
  route_table_id = aws_route_table.natgateway.id
  subnet_id      = aws_subnet.private_subnet[each.value.az].id
}