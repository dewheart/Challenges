locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
}

resource "aws_security_group" "windows_sg" {
  name        = "${local.default_tag}-windows-sg"
  description = "Enables RDP, HTTP and HTTPS access."
  vpc_id      = var.VpcIdentity

  ingress {
    description = "RDP Traffic From NIH internal network"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  ingress {
    description = "Allows all traffic to itself from inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

  ingress {
    description = "HTTP Traffic From NIH internal network"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  ingress {
    description = "HTTP Traffic From Administrators IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  egress {
    description = "All Traffic Egress To Any IP"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.AnyIP
  }

  tags = {
    Name        = "${upper(local.default_tag)} Windows Security Group"
    Environment = var.EnvironmentName
  }
}

resource "aws_security_group" "linux_sg" {
  name        = "${local.default_tag}-linux-sg"
  description = "Enables SSH, HTTP and HTTPS access."
  vpc_id      = var.VpcIdentity

  ingress {
    description = "SSH Traffic From NIH internal network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  ingress {
    description = "Allows all traffic to itself from inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
  }

  ingress {
    description = "HTTPS Traffic From NIH internal network"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  ingress {
    description = "HTTP Traffic From NIH internal network"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.NIHCidr
  }

  egress {
    description = "All Traffic Egress To Any IP"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.AnyIP
  }

  tags = {
    Name        = "${upper(local.default_tag)} Linux Security Group"
    Environment = var.EnvironmentName
  }
}