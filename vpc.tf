# VPC ---> roboshop-dev
resource "aws_vpc" "main"{
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_hostnames = "true"

    tags = merge(
        var.vpc_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}

# IGW ---> roboshop-dev
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id   # Association with VPC

  tags = merge(
        var.igw_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}

# Public subnets ---> roboshop-dev-public-us-east-1a
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
        var.public_subnet_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        }
    )
}

# Private subnets ---> roboshop-dev-private-us-east-1a
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
        var.private_subnet_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        }
    )
}

# Private subnets ---> roboshop-dev-public-us-east-1a
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
        var.database_subnet_tags, 
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
        }
    )
}


# AWS Elastic IP
 resource "aws_eip" "nat" {
   domain = "vpc"
     tags = merge(
         var.eip_tags,
         local.common_tags,
         {
            Name = "${var.project}-${var.environment}"
         }
  )
 }


# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
         var.nat_gateway_tags,
         local.common_tags,
         {
            Name = "${var.project}-${var.environment}"
         }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
} 


#Route table -- Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
         var.public_route_table_tags,
         local.common_tags,
         {
            Name = "${var.project}-${var.environment}-public"
         }
  )
}

#Route table -- Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
         var.private_route_table_tags,
         local.common_tags,
         {
            Name = "${var.project}-${var.environment}-private"
         }
  )
}

#Route table -- Database
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
         var.database_route_table_tags,
         local.common_tags,
         {
            Name = "${var.project}-${var.environment}-database"
         }
  )
}


