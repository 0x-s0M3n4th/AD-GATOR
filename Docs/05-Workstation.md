# Phase 5 – Workstation Setup and Domain Integration

## Objective

Provision a Windows 10 workstation in Azure and integrate it into the Active Directory domain (`kurukshetra.local`) using Terraform and Azure CLI, followed by proper OU placement and GPO application.

---

# 1. Infrastructure Setup (Terraform)

## Overview

The workstation was provisioned using Terraform by extending the existing `compute.tf` configuration.

## Components Added

### 1. Network Interface (NIC)

* Attached to `workstation-subnet (10.0.2.0/24)`
* Configured with Domain Controller DNS

```hcl
resource "azurerm_network_interface" "ws_nic" {
  name                = "${var.ws_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.workstation.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.ws_pip.id
  }

  dns_servers = ["10.0.1.10"]
}
```

---

### 2. Public IP

```hcl
resource "azurerm_public_ip" "ws_pip" {
  name                = "${var.ws_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method   = "Static"
  sku                 = "Standard"
}
```

---

### 3. Windows 10 Virtual Machine

```hcl
resource "azurerm_windows_virtual_machine" "ws" {
  name                = var.ws_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.ws_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.ws_nic.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "win10-22h2-pro"
    version   = "latest"
  }
}
```

---

# 2. Domain Join Using Azure CLI

## Approach

Instead of relying on Terraform extensions, domain joining was executed using Azure CLI to avoid reboot-related execution issues.

---

## Domain Join Command

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-ws \
  --command-id RunPowerShellScript \
  --scripts '
  $pass = ConvertTo-SecureString "Password@123" -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential("KURUKSHETRA\krishna", $pass)
  Add-Computer -DomainName "kurukshetra.local" -Credential $cred -Force
  '
```

---

## Key Observation

```text
WARNING: The changes will take effect after you restart the computer
```

This indicates successful domain join pending reboot.

---

# 3. Restart Workstation

```bash
az vm restart \
  --resource-group ad-gator-rg \
  --name ad-gator-ws
```

---

# 4. Verification Steps

## 4.1 Verify Domain Membership

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-ws \
  --command-id RunPowerShellScript \
  --scripts "systeminfo | findstr /B /C:\"Domain\""
```

### Expected Output

```text
Domain: kurukshetra.local
```

---

## 4.2 Verify from Domain Controller

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "Get-ADComputer -Filter * | Select Name"
```

### Expected Output

```text
ad-gator-ws
```

---

# 5. Organizational Unit Placement

## Check Current Location

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  Get-ADComputer ad-gator-ws -Properties DistinguishedName | 
  Select Name, DistinguishedName
  "
```

---

## Move to Indraprastha OU

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  \$comp = Get-ADComputer ad-gator-ws
  Move-ADObject -Identity \$comp.DistinguishedName \
    -TargetPath 'OU=Workstations,OU=Indraprastha,DC=kurukshetra,DC=local'
  "
```

---

## Verify OU Placement

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  Get-ADComputer ad-gator-ws -Properties DistinguishedName | 
  Select Name, DistinguishedName
  "
```

### Expected Output

```text
CN=ad-gator-ws,OU=Workstations,OU=Indraprastha,DC=kurukshetra,DC=local
```

---

# 6. Apply Group Policy

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-ws \
  --command-id RunPowerShellScript \
  --scripts "gpupdate /force"
```

---

# 7. Key Learnings

## 1. Domain Admin Confusion

* Initial attempts used:

  ```text
  KURUKSHETRA\Administrator
  ```
* This failed because the account was not usable in this setup

### Correct Approach

```text
KURUKSHETRA\krishna
```

* This user was explicitly created and added to **Domain Admins**

---

## 2. Separation of Credentials

| Type                        | Purpose            |
| --------------------------- | ------------------ |
| Local VM (terraform.tfvars) | Initial RDP access |
| Domain Users                | AD authentication  |

---

## 3. Azure Run Command Limitation

* Combining domain join and reboot causes execution issues
* Best practice:

  * Join domain
  * Restart separately

---

## 4. DNS is Critical

* Workstation must use Domain Controller IP
* Without DNS, domain join fails regardless of credentials

---

# 8. Final Outcome

* Windows 10 workstation successfully provisioned
* Joined to `kurukshetra.local`
* Placed in correct OU (`Indraprastha → Workstations`)
* GPO applied successfully
* Verified using Azure CLI
