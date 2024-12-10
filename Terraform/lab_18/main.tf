# main.tf

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "memo_lab18_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "memo-lab18-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "memo_lab18_igw" {
  vpc_id = aws_vpc.memo_lab18_vpc.id

  tags = {
    Name = "memo-lab18-igw"
  }
}

# Public Subnets
resource "aws_subnet" "memo_lab18_public_1" {
  vpc_id                  = aws_vpc.memo_lab18_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "memo-lab18-public-subnet-1"
  }
}

resource "aws_subnet" "memo_lab18_public_2" {
  vpc_id                  = aws_vpc.memo_lab18_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "memo-lab18-public-subnet-2"
  }
}

# Route Table
resource "aws_route_table" "memo_lab18_public" {
  vpc_id = aws_vpc.memo_lab18_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.memo_lab18_igw.id
  }

  tags = {
    Name = "memo-lab18-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "memo_lab18_public_1" {
  subnet_id      = aws_subnet.memo_lab18_public_1.id
  route_table_id = aws_route_table.memo_lab18_public.id
}

resource "aws_route_table_association" "memo_lab18_public_2" {
  subnet_id      = aws_subnet.memo_lab18_public_2.id
  route_table_id = aws_route_table.memo_lab18_public.id
}

# EC2 Module instances
module "memo_lab18_ec2_1" {
  source = "./modules/ec2"

  vpc_id        = aws_vpc.memo_lab18_vpc.id
  subnet_id     = aws_subnet.memo_lab18_public_1.id
  instance_name = "memo-lab18-nginx-server-1"
  ami_id        = "ami-0453ec754f44f9a4a"  # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name      = "amazon"
}

module "memo_lab18_ec2_2" {
  source = "./modules/ec2"

  vpc_id        = aws_vpc.memo_lab18_vpc.id
  subnet_id     = aws_subnet.memo_lab18_public_2.id
  instance_name = "memo-lab18-nginx-server-2"
  ami_id        = "ami-0453ec754f44f9a4a"  # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  key_name      = "amazon"
}
