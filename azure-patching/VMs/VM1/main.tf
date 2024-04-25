locals {
  default_tag = "${var.ProgramName}-${var.EnvironmentName}"
  vm_name     = "${upper(var.ProgramName)}${upper(var.EnvironmentName)}${upper(var.VM_Name)}"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${local.vm_name}-nic"
  resource_group_name = var.azurerm_resource_group
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.Subnet_Id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${local.vm_name}-PublicIp"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  allocation_method   = "Dynamic"

  tags = {
    environment = var.EnvironmentName
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = local.vm_name
  resource_group_name   = var.azurerm_resource_group
  location              = var.location
  size                  = var.VM_Size
  admin_username        = var.VM_LocalAdmins
  admin_password        = var.VM_Password
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  os_disk {
    name                 = "${local.vm_name}-disk1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.VM_Disk1_Size
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    #    version   = "latest"
    version = "20348.2340.240303"
  }

#  custom_data = base64encode("${file("userdata_winvm.ps1")}")

  tags = {
    environment = var.EnvironmentName
  }
}