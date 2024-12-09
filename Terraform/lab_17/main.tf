# provider.tf
provider "aws" {
  region = "us-east-1"
}

/*
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --enable-dns-hostnames \
    --enable-dns-support \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=ivolve}]'
*/
# vpc.tf
resource "aws_vpc" "ivolve_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ivolve"
  }
}

# Data block to fetch VPC ID
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["ivolve"]
  }
  depends_on = [aws_vpc.ivolve_vpc]
}

# networking.tf
resource "aws_subnet" "memo_lab17_public_subnet" {
  vpc_id                  = data.aws_vpc.selected.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "memo-lab17-public-subnet"
  }
}

resource "aws_subnet" "memo_lab17_private_subnet" {
  vpc_id            = data.aws_vpc.selected.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "memo-lab17-private-subnet"
  }
}

resource "aws_internet_gateway" "memo_lab17_igw" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Name = "memo-lab17-igw"
  }
}

resource "aws_route_table" "memo_lab17_public_rt" {
  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.memo_lab17_igw.id
  }

  tags = {
    Name = "memo-lab17-public-rt"
  }
}

resource "aws_route_table_association" "memo_lab17_public" {
  subnet_id      = aws_subnet.memo_lab17_public_subnet.id
  route_table_id = aws_route_table.memo_lab17_public_rt.id
}

# security.tf
resource "aws_security_group" "memo_lab17_ec2_sg" {
  name        = "memo-lab17-ec2-security-group"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "memo-lab17-ec2-sg"
  }
}

resource "aws_security_group" "memo_lab17_rds_sg" {
  name        = "memo-lab17-rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.memo_lab17_ec2_sg.id]
  }

  tags = {
    Name = "memo-lab17-rds-sg"
  }
}

# ec2.tf
resource "aws_instance" "memo_lab17_web_server" {
  ami           = "ami-0453ec754f44f9a4a" # Amazon Linux 2023 AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.memo_lab17_public_subnet.id

  vpc_security_group_ids = [aws_security_group.memo_lab17_ec2_sg.id]
  key_name              = "jenkins" # Replace with your key pair name

  tags = {
    Name = "memo-lab17-web-server"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ec2-ip.txt"
  }
}

# rds.tf
resource "aws_db_subnet_group" "memo_lab17_db_subnet_group" {
  name       = "memo-lab17-db-subnet-group"
  subnet_ids = [aws_subnet.memo_lab17_private_subnet.id, aws_subnet.memo_lab17_public_subnet.id]

  tags = {
    Name = "memo-lab17-db-subnet-group"
  }
}

resource "aws_db_instance" "memo_lab17_db" {
  identifier           = "memo-lab17-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = var.db_username
  password            = var.db_password # Better to use variables or secrets management
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.memo_lab17_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.memo_lab17_db_subnet_group.name

  tags = {
    Name = "memo-lab17-rds"
  }
}

# outputs.tf
output "ec2_public_ip" {
  value = aws_instance.memo_lab17_web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.memo_lab17_db.endpoint
}
