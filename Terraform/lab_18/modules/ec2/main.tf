# modules/ec2/main.tf

resource "aws_security_group" "memo_lab18_nginx" {
  name        = "${var.instance_name}-sg"  # This will make the security group name unique
  description = "Security group for Nginx servers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "memo_lab18_nginx" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.memo_lab18_nginx.id]

  # Updated user_data for Amazon Linux 2023
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install nginx -y

              # Get IMDSv2 token
              TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

              # Get instance public IP and DNS
              PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
              PUBLIC_DNS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)

              # Create custom nginx configuration
              cat > /etc/nginx/conf.d/default.conf << 'EOL'
              server {
                  listen 80;
                  server_name _;
                  
                  root /usr/share/nginx/html;
                  
                  location / {
                      index index.html;
                  }
              }
              EOL

              # Create custom index.html with public IP and DNS
              cat > /usr/share/nginx/html/index.html << EOL
              <!DOCTYPE html>
              <html>
              <head>
                  <title>Welcome</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                          background-color: #f0f0f0;
                      }
                      .content {
                          text-align: center;
                          padding: 20px;
                          background-color: white;
                          border-radius: 10px;
                          box-shadow: 0 0 10px rgba(0,0,0,0.1);
                      }
                      h1, h2 {
                          color: #333;
                      }
                      p {
                          color: #666;
                          font-size: 1.2em;
                      }
                      .server-info {
                          margin: 20px 0;
                          padding: 15px;
                          background-color: #f8f9fa;
                          border-radius: 5px;
                      }
                  </style>
              </head>
              <body>
                  <div class="content">
                      <div class="server-info">
                          <p><strong>Public IP:</strong> $PUBLIC_IP</p>
                          <p><strong>Public DNS:</strong> $PUBLIC_DNS</p>
                      </div>
                      <H1>Hope you are well Memo</H1>
                  </div>
              </body>
              </html>
              EOL

              # Start and enable nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = var.instance_name
  }
}
