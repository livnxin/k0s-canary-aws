# VPC itself, subnets, IGW, and route tables are all $0 - always free,
# regardless of usage. No NAT Gateway anywhere in this module on purpose:
# NAT Gateway bills hourly even when idle and is NOT free-tier eligible.
# Since our nodes only need outbound internet for pulling images/updates,
# a public subnet + IGW + public IP per instance is enough and free.

resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "aws_gateway" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_subnet" "control" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr, 13, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment}-control-subnet"
  }
}

resource "aws_subnet" "worker" {
  vpc_id                  = aws_vpc.aws_vpc.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.environment}-worker-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_gateway.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
