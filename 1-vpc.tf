terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>4.62"
    }

    helm = {
      source        = "hashicorp/helm"
      version       = "~> 2.9"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block            = var.vpc_cidr_block

  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "private_ap_southeast_2a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "ap-southeast-2a"

  tags = {
    "Name"                              = "private-us-east-2a"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/cilsy-final" = "owned"
  }
}

resource "aws_subnet" "public_ap_southeast_2a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                              = "public-ap-southeast-2a"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/cilsy-final" = "owned"
  }
}

resource "aws_subnet" "private_ap_southeast_2b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "ap-southeast-2b"

  tags = {
    "Name"                              = "private-ap-southeast-2b"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/cilsy-final" = "owned"
  }
}

resource "aws_subnet" "public_ap_southeast_2b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                              = "public-ap-southeast-2b"
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/cilsy-final" = "owned"
  }
}

resource "aws_eip" "this" {
  vpc             = true

  tags            = {
    Name          = "${var.env}-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id   = aws_eip.this.id
  subnet_id       = aws_subnet.public_ap_southeast_2a.id
  
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

resource "aws_route_table_association" "private_ap_southeast_2a" {
  subnet_id      = aws_subnet.private_ap_southeast_2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_ap_southeast_2b" {
  subnet_id      = aws_subnet.private_ap_southeast_2b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_ap_southeast_2a" {
  subnet_id      = aws_subnet.public_ap_southeast_2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_ap_southeast_2b" {
  subnet_id      = aws_subnet.public_ap_southeast_2b.id
  route_table_id = aws_route_table.public.id
}

