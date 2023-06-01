terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.62"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block            = var.vpc_cidr_block

  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.env}-main"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "private" {
  count               = length(var.private_subnets)

  vpc_id              = aws_vpc.this.id
  cidr_block          = var.private_subnets[count.index]
  availability_zone   = var.azs[count.index]

  tags                = merge( 
    { Name = "${var.env}-private-${var.azs[count.index]}" },
    var.private_subnet_tags
    )
}

resource "aws_subnet" "public" {
  count               = length(var.public_subnets)

  vpc_id              = aws_vpc.this.id
  cidr_block          = var.public_subnets[count.index]
  availability_zone   = var.azs[count.index]

  tags                = merge( 
    { Name = "${var.env}-public-${var.azs[count.index]}" },
    var.public_subnet_tags
    )
}

resource "aws_eip" "this" {
  vpc             = true

  tags            = {
    Name          = "${var.env}-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id   = aws_eip.this.id
  subnet_id       = aws_subnet.public[0].id
  
  tags            = {
    Name          = "${var.env}-nat"
  }

  depends_on      = [aws_internet_gateway.this]

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block      =  "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.env}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block      =  "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id         = aws_subnet.private[count.index].id
  route_table_id    = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id         = aws_subnet.public[count.index].id
  route_table_id    = aws_route_table.public.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}