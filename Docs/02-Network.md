# Phase 2: Azure Network Setup (Detailed Implementation)

---

## Objective

Design and deploy a segmented, secure Azure network using Terraform to support a cloud-based Active Directory attack-defense lab. Our goal is to make a `/16` virtual network and subnet it into 4 distinct parts for our 4 different devices to simulate a real world network. Then we would make some `Firewall Rules` for `SSH, RDP` to access the machines from internet.

---

## Design Goals

* Isolate the machines using subnet segmentation
* Restrict administrative access using IP-based filtering
* Implement firewall controls using Network Security Groups (NSGs)
* Maintain reusable and clean Terraform configuration

---

## Network Architecture

### Virtual Network (VNet)

```text
Address Space: 10.0.0.0/16
```

---

### Subnet Design

| Subnet Name        | Purpose           | CIDR Block  |
| ------------------ | ----------------- | ----------- |
| domain-subnet      | Domain Controller | 10.0.1.0/24 |
| workstation-subnet | Windows Client    | 10.0.2.0/24 |
| attacker-subnet    | Kali Linux        | 10.0.3.0/24 |
| monitoring-subnet  | Wazuh Server      | 10.0.4.0/24 |

---

## Terraform File Structure

_Make sure you create the `terraform.tfvars` file by yourself, it will contain your public IP address for accessing the mahcines via `RDP,SSH`_ 

```bash
terraform/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── network.tf
├── security.tf
└── terraform.tfvars
```

---

# VARIABLES CONFIGURATION

## File: `variables.tf`

```hcl
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "ad-gator-rg"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "Central India"
}

variable "my_ip" {
  description = "Allowed admin public IP in CIDR format"
  type        = string
}
```

---

## File: `terraform.tfvars`

```hcl
my_ip = "PASTE_YOUR_PUBLIC_IP/CIDR"
```
**You can find your public IP using the following step:**
```bash
curl ifconfig.me
```
_Then check it online about your subnet/ If you can calculate that would also work_

---

## Security Note

* `terraform.tfvars` is **excluded via `.gitignore`**
* Prevents exposure of sensitive or environment-specific data

---

# NETWORK CONFIGURATION

## File: `network.tf`

```hcl
resource "azurerm_virtual_network" "vnet" {
  name                = "ad-gator-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Domain Subnet
resource "azurerm_subnet" "domain" {
  name                 = "domain-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Workstation Subnet
resource "azurerm_subnet" "workstation" {
  name                 = "workstation-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Attacker Subnet
resource "azurerm_subnet" "attacker" {
  name                 = "attacker-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Monitoring Subnet
resource "azurerm_subnet" "monitoring" {
  name                 = "monitoring-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]

  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

---

# SECURITY CONFIGURATION

## File: `security.tf`

```hcl
resource "azurerm_network_security_group" "nsg" {
  name                = "ad-gator-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow RDP (Windows)
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
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Allow SSH (Linux)
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
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
```

---

# DEPLOYMENT WORKFLOW

## Step 1: Format Code

```bash
terraform fmt
```

---

## Step 2: Validate Configuration

```bash
terraform validate
```

---

## Step 3: Plan Execution

```bash
terraform plan
```

---

## Step 4: Apply Configuration

```bash
terraform apply
```

Confirm:

```text
yes
```

---

# VERIFICATION

## List VNets

```bash
az network vnet list --output table
```

---

## List Subnets

```bash
az network vnet subnet list \
  --resource-group ad-gator-rg \
  --vnet-name ad-gator-vnet \
  --output table
```

---

## List NSG

```bash
az network nsg list --output table
```

---

# CLEANUP

```bash
terraform destroy
```

---

# ISSUES FACED & RESOLUTIONS

## 1. Invalid Number Literal

**Error:**

```
Invalid number literal
```

**Cause:**
IP not quoted in tfvars

**Wrong:**

```hcl
my_ip = MY_PUBLIC_IP/CIDR
```

**Correct:**

```hcl
my_ip = "MY_PUBLIC_IP/CIDR"
```

---

## 2. NSG Not Enforced

**Cause:**
NSG was created but not attached to subnets

**Fix:**

```hcl
network_security_group_id = azurerm_network_security_group.nsg.id
```

---

## 4. Overexposed Ports

**Cause:**
Using:

```hcl
"*"
```
_Which basically means giving the whole internet to access of my `RDP,SSH` port_

**Fix:**
Restrict to:

```hcl
var.my_ip
```

---

# KEY LEARNINGS

* Azure VNet acts as isolated network boundary
* Subnet segmentation mimics enterprise network zones
* NSGs act as firewall controls
* Terraform variables improve maintainability
* NSG must be explicitly attached to enforce rules
* Secure access requires IP restriction

---

# BEST PRACTICES

* Never expose RDP/SSH to entire internet
* Use `/32` CIDR for admin access
* Always validate Terraform configs before apply
* Use `.tfvars` for environment-specific values
* Keep state files out of version control

---

