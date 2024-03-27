locals {
  account_id  = data.aws_caller_identity.current.account_id
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
  ec2_name    = "${upper(var.ProgramName)}${upper(var.EnvironmentName)}${upper(var.EC2Name)}"
}

resource "aws_security_group" "websg" {
  name        = "${local.default_tag}-webservers-sg"
  description = "Enable RDP, HTTP and HTTPS access."
  vpc_id      = var.VpcIdentity

  ingress {
    description = "RDP Traffic From Administrators IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = var.MyIP
  }

  ingress {
    description = "HTTP Traffic From Administrators IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.MyIP
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
    Environment = var.EnvironmentName
  }
}

resource "aws_key_pair" "EC2Key" {
  key_name   = "${local.default_tag}-${lower(var.WindowsKey)}"
  public_key = tls_private_key.EC2Key-Private.public_key_openssh
}

resource "tls_private_key" "EC2Key-Private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_ssm_parameter" "WindowsKeySSM" {
  name        = "/${var.EC2Name}/WindowsKeySSM"
  description = "The SSM parameter storing the webserver key pair"
  type        = "SecureString"
  value       = tls_private_key.EC2Key-Private.private_key_pem
  tags = {
    EnvName = "${local.default_tag}"
  }
}

resource "aws_instance" "webserver" {
  ami                                  = var.InstanceAMI
  subnet_id                            = var.AppSubnet
  instance_type                        = var.InstanceType
  key_name                             = aws_key_pair.EC2Key.key_name
  associate_public_ip_address          = true
  vpc_security_group_ids               = [aws_security_group.websg.id]
  iam_instance_profile                 = "${local.default_tag}-ssmpatchprofile"
  instance_initiated_shutdown_behavior = "terminate"
  #Specify IMDSv2 as required
  root_block_device {
    volume_size           = var.Volume1
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }
  ebs_block_device {
    device_name           = "xvdf"
    volume_size           = var.Volume2
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }
  user_data = <<-EOF
<powershell>
Rename-Computer -NewName ${local.ec2_name} -Force -Restart
#    $User = ${var.EC2LocalAdmins}
#    $Password = ConvertTo-SecureString '${var.EC2Password}' -AsPlainText -Force
#    $FullName = ${var.EC2LocalAdminsFullName}
#    New-LocalUser $User -Password $Password -FullName $FullName -Description 'Local account for CIT POC Admins.' -AccountNeverExpires
#    Add-LocalGroupMember -Group "Administrators" -Member $User
#    Disable-LocalUser -Name "Administrator"
Disable-LocalUser -Name "Guest"
Set-TimeZone -Name 'Eastern Standard Time' -PassThru
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Stop-Service -Name ShellHWDetection
Get-Disk | Where PartitionStyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "Apps Drive" -Confirm:$false
Start-Service -Name ShellHWDetection
</powershell>
	EOF
  tags = {
    Name    = "${local.ec2_name}"
    EnvName = var.EnvironmentName
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "${lower(local.ec2_name)}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120" #seconds
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  #  alarm_actions       = [aws_sns_topic.sns.arn] #create ses, subscription and topic
  #  ok_actions          = [aws_sns_topic.sns.arn]
  insufficient_data_actions = []
  #Add alarm notification - SNSTopic, Add EC2 action or Auto Scaling Action if needed.
  dimensions = {
    InstanceId = aws_instance.webserver.id
  }
}