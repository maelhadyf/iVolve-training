# ec2.tf
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [aws_security_group.example.id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-server"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [tags["Environment"]]
    replace_triggered_by = [
      aws_security_group.example.ingress
    ]
  }
}
