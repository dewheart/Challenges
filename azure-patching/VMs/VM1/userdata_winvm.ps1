Rename-Computer -NewName ${local.ec2_name} -Force -Restart
Set-TimeZone -Name 'Eastern Standard Time' -PassThru
Install-WindowsFeature -name Web-Server -IncludeManagementTools