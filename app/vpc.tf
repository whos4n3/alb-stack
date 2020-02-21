# Initialising AWS Provider in the correct region
provider "aws" {
  region = var.aws_region
}

#setting up VPC
data "aws_availability_zones" "available" {}
resource "aws_vpc" "vpc_methods" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = merge(var.default_tags, map("Name", "Methods VPC"))
  
}
resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc_methods.id
  cidr_block = "10.0.${10+count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.default_tags, map("Name", "PublicSubnet"))
  
}
resource "aws_subnet" "private_subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc_methods.id
  cidr_block = "10.0.${20+count.index}.0/24"
  availability_zone= data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.default_tags, map("Name", "PrivateSubnet"))
}
# adding internet gateway for external communication
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id =  aws_vpc.vpc_methods.id 

  tags = merge(var.default_tags, map("Name", "Methods IGW"))
}

# create external route to IGW
resource "aws_route" "external_route" {
  route_table_id         = aws_vpc.vpc_methods.main_route_table_id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id 
}

# adding an elastic IP
resource "aws_eip" "elastic_ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
}

# creating the NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = merge(var.default_tags, map("Name", "Nat GW"))
}

# creating private route table 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_methods.id   
  tags = merge(var.default_tags, map("Name", "Private RouteTable"))    
}

# adding private route table to nat
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# associating public subnet to public route table
resource "aws_route_table_association" "public_subnet_association" {
    count = length(var.subnet_cidrs_pub)
  subnet_id       = element(aws_subnet.public_subnet.*.id, count.index)
  #subnet_id      = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id,aws_subnet.public_subnet[2].id]
  route_table_id = aws_vpc.vpc_methods.main_route_table_id
}

# associating private subnet to private route table
resource "aws_route_table_association" "private_subnet_association1" {
  count = length(var.subnet_cidrs_priv)
  subnet_id       = element(aws_subnet.private_subnet.*.id, count.index)
  #subnet_id      = [aws_subnet.private_subnet[3].id,aws_subnet.private_subnet[2].id] 
  route_table_id = aws_route_table.private_route_table.id
} 

# security group to be attached to our instance
resource "aws_security_group" "ec2-security-group" {
  name        = "Backend Security Group"
  description = "Backend  Security Group"

  # allowing SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allowing web connections since it runs a web server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks  = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.vpc_methods.id
}

resource "aws_security_group" "elb-security-group" {
  name        = "Frontend Security Group"
  description = "Frontend  Security Group"


  # allowing web connections via http and https

    
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks  = ["10.0.0.0/16"]
  }

  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.vpc_methods.id
}