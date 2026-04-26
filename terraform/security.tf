resource "azurerm_network_security_group" "nsg" {
  name                = "ad-gator-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

# Allow RDP (for Windows machines)

resource "azurerm_network_security_rule" "rdp" {
  name                        = "Allow-RDP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
# source_address_prefix means anyone can connect to this machine using RDP from the internet.

# Allow SSH (for Kali/Linux)

resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# NSG Association - Domain Subnet
resource "azurerm_subnet_network_security_group_association" "domain_assoc" {
  subnet_id                 = azurerm_subnet.domain.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Workstation Subnet
resource "azurerm_subnet_network_security_group_association" "workstation_assoc" {
  subnet_id                 = azurerm_subnet.workstation.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Attacker Subnet
resource "azurerm_subnet_network_security_group_association" "attacker_assoc" {
  subnet_id                 = azurerm_subnet.attacker.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Monitoring Subnet
resource "azurerm_subnet_network_security_group_association" "monitoring_assoc" {
  subnet_id                 = azurerm_subnet.monitoring.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
