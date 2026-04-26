# Phase 3: Domain Controller Deployment (Azure VM)

---

## Objective

Deploy a Windows Server 2022 Virtual Machine in Azure that will act as the **Domain Controller (DC)** for the Active Directory lab.

---

## Design Overview

The Domain Controller is placed inside the **domain-subnet** with:

* Static private IP for stability
* Public IP for remote administration (RDP)
* NSG-protected access restricted to a trusted IP

---

## Architecture Placement

| Component  | Value           |
| ---------- | --------------- |
| Subnet     | domain-subnet   |
| Private IP | 10.0.1.10       |
| Access     | RDP (Port 3389) |
| Public IP  | Static          |

---

## Terraform File Used

```bash id="structure-dc"
terraform/compute.tf
```

---

# VARIABLES CONFIGURATION

## variables.tf

```hcl id="vars-dc"
variable "admin_username" {
  description = "Admin username for VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VM"
  sensitive   = true
}
```

---

## terraform.tfvars

```hcl id="tfvars-dc"
admin_password = "YourStrongPassword123!"
```

---

## Password Requirements

* Minimum 12 characters
* Uppercase + lowercase
* Number
* Special character

---

# PUBLIC IP CONFIGURATION

## compute.tf

```hcl id="public-ip-dc"
resource "azurerm_public_ip" "dc_pip" {
  name                = "dc-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}
```

---

# 🔌 NETWORK INTERFACE CONFIGURATION

```hcl id="nic-dc"
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
```

---

# WINDOWS SERVER VM DEPLOYMENT

```hcl id="vm-dc"
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
```

---

# DEPLOYMENT STEPS

## Step 1: Format Code

```bash id="fmt-dc"
terraform fmt
```

---

## Step 2: Validate

```bash id="validate-dc"
terraform validate
```

---

## Step 3: Plan

```bash id="plan-dc"
terraform plan
```

---

## Step 4: Apply

```bash id="apply-dc"
terraform apply
```

Confirm:

```text id="confirm-dc"
yes
```

---

## Deployment Time

* Approx: 2–5 minutes

---

# VERIFICATION

## Get Public IP

```bash id="get-ip"
az vm list-ip-addresses --output table
```

---

# REMOTE ACCESS (RDP)

## Tool Used

* FreeRDP (Linux RDP client)

---

## Installation (Arch Linux)

```bash id="install-rdp"
sudo pacman -S freerdp
```

---

## Binary Issue (Observed)

### Problem:

```text id="rdp-error"
xfreerdp: command not found
```

### Cause:

Binary installed as:

```text id="rdp-binary"
xfreerdp3
```

---

## Fix

```bash id="check-bin"
ls /usr/bin | grep freerdp
```

---

## RDP Connection Command

```bash id="rdp-connect"
xfreerdp3 /v:<PUBLIC_IP> /u:azureuser /p:'YourStrongPassword123!' /cert:ignore
```

---

## Optional (Better UX)

```bash id="rdp-advanced"
xfreerdp3 /v:<IP> /u:azureuser /p:'PASS' /cert:ignore /dynamic-resolution
```

---

# KEY LEARNINGS

* Importance of static IP for Domain Controller
* Azure VM deployment workflow
* NIC + Public IP association
* Secure remote access using NSG rules
* Linux-based RDP access setup

---

# BEST PRACTICES

* Avoid exposing RDP publicly in production
* Use IP-restricted access (as implemented)
* Use strong credentials
* Separate network and compute layers

---
