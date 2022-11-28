# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating VPC
resource "aws_vpc" "vpc" {
  
  # IP Range for the VPC
  cidr_block = var.vpc_cidr
  
  # Enabling automatic hostname assigning
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidrs_public[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet${count.index}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.subnet_cidrs_private)}"

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidrs_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet${count.index}-${data.aws_availability_zones.available.names[count.index]}"
  }
}

# # Creating Public subnet
# resource "aws_subnet" "public_subnet1" {
#   depends_on = [
#     aws_vpc.vpc
#   ]
  
#   # VPC in which subnet has to be created
#   vpc_id = aws_vpc.vpc.id
  
#   # IP Range of this subnet
#   cidr_block = "192.168.0.0/24"
  
#   # Data Center of this subnet
#   availability_zone = data.aws_availability_zones.available.names[0]
  
#   # Enabling automatic public IP assignment on instance launch
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Public Subnet 1"
#   }
# }

# # Creating Public subnet
# resource "aws_subnet" "public_subnet2" {
#   depends_on = [
#     aws_vpc.vpc
#   ]
  
#   # VPC in which subnet has to be created
#   vpc_id = aws_vpc.vpc.id
  
#   # IP Range of this subnet
#   cidr_block = "192.168.2.0/24"
  
#   # Data Center of this subnet
#   availability_zone = data.aws_availability_zones.available.names[1]
  
#   # Enabling automatic public IP assignment on instance launch
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Public Subnet 2"
#   }
# }

# Creating Private subnet
# resource "aws_subnet" "private_subnet1" {
#   depends_on = [
#     aws_vpc.vpc,
#     aws_subnet.public_subnet1,
#     aws_subnet.public_subnet2
#   ]
  
#   # VPC in which subnet has to be created
#   vpc_id = aws_vpc.vpc.id
  
#   # IP Range of this subnet
#   cidr_block = "192.168.1.0/24"
  
#   # Data Center of this subnet
#   availability_zone = data.aws_availability_zones.available.names[0]
  
#   tags = {
#     Name = "Private Subnet 1"
#   }
# }

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.private,
    aws_subnet.public
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Creating an Route Table for the public subnet
resource "aws_route_table" "public-subnet-rtb" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.internet_gateway
  ]

  # VPC ID
  vpc_id = aws_vpc.vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.vpc_name}-rtb-public"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnet_cidrs_public)}"
 
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = aws_route_table.public-subnet-rtb.id
}

resource "aws_route_table" "private-subnet-rtb" {
  depends_on = [
    aws_vpc.vpc
  ]

  # VPC ID
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-rtb-private"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.subnet_cidrs_private)}"
 
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = aws_route_table.private-subnet-rtb.id
}

# Creating a resource for the Route Table Association
# resource "aws_route_table_association" "RT_IG_Association_subnet1" {

#   depends_on = [
#     aws_vpc.vpc,
#     aws_subnet.public_subnet1,
#     aws_subnet.private_subnet1,
#     aws_route_table.public-subnet-RT,
#     aws_subnet.public_subnet2
#   ]

# # Public Subnet ID
#   subnet_id      = aws_subnet.public_subnet1.id

# #  Route Table ID
#   route_table_id = aws_route_table.public-subnet-RT.id
# }

# resource "aws_route_table_association" "RT_IG_Association_subnet2" {

#   depends_on = [
#     aws_vpc.vpc,
#     aws_subnet.public_subnet1,
#     aws_subnet.private_subnet1,
#     aws_route_table.public-subnet-RT,
#     aws_subnet.public_subnet2
#   ]

# # Public Subnet ID
#   subnet_id      = aws_subnet.public_subnet2.id

# #  Route Table ID
#   route_table_id = aws_route_table.public-subnet-RT.id
# }