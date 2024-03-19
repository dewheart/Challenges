provider "aws" {
  #  version    = "4.67.0"
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_security_group" "websg" {
  name        = "webservers-sg"
  description = "Enable SSH, HTTP and HTTPS access."
  vpc_id      = var.VpcIdentity

  ingress {
    description = "SSH Traffic From Ade IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.MyIP
  }

  ingress {
    description = "HTTP Traffic From Ade IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.MyIP
  }

  ingress {
    description = "HTTP Traffic From CyberArk VPN IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.CyberArkVPNIP
  }

  egress {
    description = "HTTP Traffic To Any IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.AnyIP
  }

  egress {
    description = "HTTPS Traffic To Any IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.AnyIP
  }

  tags = {
    Name = "${var.EnvName}-webservers-sg"
  }
}

resource "aws_key_pair" "EC2Key" {
  key_name   = var.pLinuxKey
  public_key = tls_private_key.EC2Key-Private.public_key_openssh
}

resource "tls_private_key" "EC2Key-Private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "LinuxKeySSM" {
  name        = "/${var.EC2Name}/LinuxKeySSM"
  description = "The SSM parameter storing the webserver key pair"
  type        = "SecureString"
  value       = tls_private_key.EC2Key-Private.private_key_pem
  tags = {
    EnvName = var.EnvName
  }
}

resource "aws_instance" "webserver" {
  ami                         = var.InstanceAMI
  subnet_id                   = var.PublicSubnet
  instance_type               = var.InstanceType
  key_name                    = aws_key_pair.EC2Key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.websg.id]
  root_block_device {
    volume_size           = var.Volume1
    volume_type           = "gp3"
    delete_on_termination = true
  }
  user_data = <<-EOF
        #!/bin/bash
        yum update -y
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        localIp=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
        && curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/local-ipv4)
        cd  /var/www/html
        echo "$localIp" >> index.html
	EOF
  tags = {
    Name    = var.EC2Name
    EnvName = var.EnvName
  }
}

output "webserver_public_ip" {
  description = "This is the public ip of the new web server"
  value       = aws_instance.webserver.public_ip
}