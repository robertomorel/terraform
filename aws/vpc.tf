# VPC
# resource "aws_vpc" "new-vpc" {
#   cidr_block = "10.0.0.0/16" # Cidr block
#   tags = {
#     Name = "rob_aws_vpc"
#   }
# }

resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16" # Cidr block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# List the Availability_Zones
data "aws_availability_zones" "available" {}

# Subnet
# resource "aws_subnet" "new-subnet" {
#   vpc_id     = aws_vpc.new-vpc.id
#   cidr_block = "10.0.0.0/24"
#   tags = {
#     Name = "${var.prefix}_subnet1"
#   }
#   availability_zone = "us-east-1a"
# }

# Subnet
# resource "aws_subnet" "new-subnet-2" {
#   vpc_id     = aws_vpc.new-vpc.id
#   cidr_block = "10.0.1.0/24"
#   tags = {
#     Name = "${var.prefix}_subnet-2"
#   }
#   availability_zone = "us-east-1b"
# }

# Subnets - Gerando duas subnets em um único recurso
resource "aws_subnet" "subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true # Todo recurso que colocarmos dentro da subnet, ele já joga um IP público
  tags = {
    Name = "${var.prefix}_subnet-${count.index}"
  }
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

##########################################################################
## VPC
### Subnet
#### Route Table
##### Internet Gateway -> Toda máquina que tiver nesta subnet, com essa route table, terá acesso à internet
##########################################################################

# Internet Gateway
resource "aws_internet_gateway" "new-igw" {
  # VPC
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Route Table
resource "aws_route_table" "new-rtb" {
  # VPC
  vpc_id = aws_vpc.new-vpc.id
  route {
    # Anexar o internet gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
}

# Associação: redes associadas ao route table
resource "aws_route_table_association" "new-rtb-association" {
  count          = 2
  route_table_id = aws_route_table.new-rtb.id
  subnet_id      = aws_subnet.subnets.*.id[count.index]
}
