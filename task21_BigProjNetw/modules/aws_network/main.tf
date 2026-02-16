#-------------------------------------------------
#Provision:
# - VPС
# - Internet Gateway
# - XX Public Subnets
# - XX Private Subnets
# - NAT Gateway in Public Subnets to give Internet access to Private Subnet
#
# Made by Vitalii Nik
#-------------------------------------------------

#----Deactive if Its module ----------------------
#provider "aws" {
#  region = "ca-central-1"
#}
#--------------------------------------------------
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

#-- Public Subnets and Routing ---------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index) #var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route = {
    сidr_block = "0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id) #length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index) # aws_subnet.public_subnets[count.index].id  
}


#-- NAT Gateway with Elastic IPs ---------------------
resource "aws_eip" "nat" {
  count = length(var.privat_subnet_cidrs)
  #vpc = true
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.privat_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index) #aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }

}


#-- Private Subnets and Routing ---------------------

resource "aws_subnet" "privat_subnets" {
  count             = length(var.privat_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.privat_subnet_cidrs, count.index) #var.privat_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  #map_public_ip_on_launch = false
  tags = {
    Name = "${var.env}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "privat_subnets" {
  count  = length(var.privat_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id #element(aws_nat_gateway.nat[*].id, count.index)
  }

  tags = {
    Name = "${var.env}-route-private-subnets"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.privat_subnets[*].id) #length(var.privat_subnet_cidrs)
  route_table_id = aws_route_table.privat_subnets[count.index].id
  subnet_id      = element(aws_subnet.privat_subnets[*].id, count.index) #aws_subnet.privat_subnets[count.index].id
}
