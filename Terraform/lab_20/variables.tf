variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Manually created VPC ID"
  type        = string
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  default = "us-east-1a"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_key_name" {
  description = "SSH key pair name"
}
