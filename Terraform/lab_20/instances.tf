# AMI Data Source
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

# private Instance
resource "aws_instance" "private" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.private.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install nginx -y
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "private-instance"
  }
}

# public Instance
resource "aws_instance" "public" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "public-instance"
  }
}

# Separate null_resource for remote-exec
resource "null_resource" "public_provisioner" {
  # Only run this after the instance is ready
  triggers = {
    instance_id = aws_instance.public.id
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<h1>Private Instance - Apache Server</h1>' | sudo tee /var/www/html/index.html"
    ]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file("C:/Users/theda/Downloads/amazon.pem")
      host                = aws_instance.public.public_ip
      timeout             = "5m"
    }
  }

  depends_on = [aws_instance.public]
}