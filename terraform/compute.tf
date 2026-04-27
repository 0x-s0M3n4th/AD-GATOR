# Domain controller Publi IP
resource "azurerm_public_ip" "dc_pip" {
  name                = "dc-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# Domain Controller NIC -> Private IP allocation
resource "azurerm_network_interface" "dc_nic" {
  name                = "dc-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.domain.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"
    public_ip_address_id          = azurerm_public_ip.dc_pip.id
  }
}

# Windows-server
resource "azurerm_windows_virtual_machine" "dc" {
  name                = "ad-gator-dc"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B2s"

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.dc_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

# Domain controller configuration 
resource "azurerm_virtual_machine_extension" "dc_bootstrap" {
  name                 = "dc-bootstrap"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  depends_on = [
    azurerm_windows_virtual_machine.dc
  ]

  settings = jsonencode({
     fileUris = [
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/bootstrap.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/promote-dc.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/post-config.ps1",

  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/ou-structure.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/move-objects.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/users.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/groups.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/memberships.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/service-accounts.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/adcs.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/shares.ps1",
  "https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/modules/gpo.ps1"
],
   commandToExecute = "powershell -ExecutionPolicy Bypass -File bootstrap.ps1"
  })
}
