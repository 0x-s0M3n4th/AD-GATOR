# Phase 6 – Attacker Machine Setup (Kali Linux on Azure)

## Objective

Provision and configure a Kali Linux attacker machine inside Azure, integrate it into the lab network (`10.0.0.0/16`), resolve cloud-specific issues, and prepare it as a Red Team attack platform.

---

# 1. Infrastructure Setup (Terraform)

## Overview

A Kali Linux VM was deployed in the dedicated attacker subnet:

```text
attacker-subnet → 10.0.3.0/24
```

This ensures logical separation between:

* Domain Controller (`10.0.1.0/24`)
* Workstations (`10.0.2.0/24`)
* Attacker (`10.0.3.0/24`)

---

## 1.1 Network Interface Configuration

* Static private IP assigned
* Public IP attached for SSH access
* DNS explicitly set to Domain Controller

```hcl
dns_servers = ["10.0.1.10"]
```
_If you want to be more realistic just set the DNS server as `8.8.8.8` which is the google's DNS, so it won't be knowing anything about the internal architecture._

### Reason

Active Directory attacks require:

* DNS resolution of domain
* Kerberos communication
* LDAP queries

---

## 1.2 Virtual Machine Configuration

Key configuration:

```hcl
size = "Standard_D2s_v3"
```

### Reason

* 2 vCPU / 8 GB RAM
* Sufficient for:

  * Enumeration
  * Lateral movement
  * Lightweight C2 operations

---

## 1.3 Marketplace Image Configuration

Kali Linux is a Marketplace image and requires, so i needed to add some Microsft terms acceptance stuff:

### Source Image

```hcl
publisher = "kali-linux"
offer     = "kali"
sku       = "kali-2026-1"
version   = "latest"
```

---

## 1.4 Plan Block (Mandatory)

```hcl
plan {
  name      = "kali-2026-1"
  product   = "kali"
  publisher = "kali-linux"
}
```

### Reason

Azure requires explicit plan metadata for Marketplace images.
Without this, deployment fails with:

```text
VMMarketplaceInvalidInput
```

---

# 2. Marketplace Agreement Handling

## Approach Used

Accepted terms using Azure CLI:

```bash
az vm image terms accept \
  --publisher kali-linux \
  --offer kali \
  --plan kali-2026-1
```

---

## Alternative (Terraform-native), not implemeneted by me(ChatGPT recommendation)

```hcl
resource "azurerm_marketplace_agreement" "kali" {
  publisher = "kali-linux"
  offer     = "kali"
  plan      = "kali-2026-1"
}
```

_You can check the code blocks from the `compute.tf` as well as `variables.tf`_

---

## Key Learning

```text
Agreement ≠ Plan
```

| Component  | Purpose                  |
| ---------- | ------------------------ |
| Agreement  | Accept legal terms       |
| Plan block | Required for VM creation |

---
# Public key generation:
_Before applying the terraform configs_
- Generate the key pairs on your machine:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/kali_azure
```
- Now print the publickey value:
```bash
cat ~/.ssh/kali_azure.pub
```
- Then add this value into your `terraform.tfvars` file:
```bash
echo "YOUR_PUBLIC_KEY_VALUE" > terraform.tfvars
```
_Make sure you put the correct path for `terraform.tfvars` file._

- Then run the apply command:
```bash
terraform apply
```

---

# 3. Accessing Kali Linux

## SSH Connection

```bash
ssh -i ~/.ssh/kali_azure kali@<PUBLIC_IP>
```

---

## Key-Based Authentication

* Public key injected via Terraform
* Private key used locally

---

# 4. Post-Deployment Issues and Fixes

---

## 4.1 Terminal Compatibility Issue

### Problem

```text
ncurses: cannot initialize terminal type (xterm-kitty)
```

---

### Cause

* Host system uses `kitty` terminal
* Kali minimal image does not support `xterm-kitty`

---

### Fix

Temporary:

```bash
export TERM=xterm
```

Permanent:

```bash
echo 'export TERM=xterm' >> ~/.zshrc
```

---

## 4.2 Broken Shell Configuration

### Problem

```text
shopt: command not found
```

---

### Cause

* `.bashrc` sourced in a `zsh` environment

---

### Fix

* Avoid using `.bashrc`
* Use `.zshrc` instead

---

## 4.3 Missing Kali Prompt (Minimal Shell)

### Problem

```text
kali@kali:~$
```

Instead of:

```text
┌──(kali㉿kali)-[~]
└─$
```

---

### Cause

* Kali cloud image is minimal
* Default `.zshrc` not fully configured

---

### Fix

```bash
cp /etc/skel/.zshrc ~/.zshrc
echo 'export TERM=xterm' >> ~/.zshrc
```

---

## 4.4 `.zshrc` Not Loading Automatically

### Problem

Prompt only appeared after:

```bash
source ~/.zshrc
```

---

### Fix

Edit:

```bash
nano ~/.zprofile
```

Add:

```bash
source ~/.zshrc
```

---

## 4.5 Hostname Resolution Issue

### Problem

```text
sudo: unable to resolve host kali
```

---

### Cause

Incorrect `/etc/hosts`

---

### Fix

```bash
sudo nano /etc/hosts
```

Set:

```text
127.0.0.1   localhost
127.0.1.1   kali
```

---


## Key Learning

```text
DNS is critical for Active Directory environments
```

---

# 5. Tool Installation Strategy

## Approach

Instead of using a full Kali install:

* Created a custom script (`kali.sh`)
* Installed only required tools

---

## Tool Categories

### System Tools (APT)

* nmap
* smbclient
* enum4linux
* ldap-utils
* proxychains
* xfreerdp

---

### Python Tools (pipx)

* impacket
* netexec (nxc)
* bloodhound-python

---

### Binary Tools

* chisel
* ligolo-ng
* sliver C2

---

### Windows Payload Tools

* mimikatz (download only)
_Later i will port my own `Akagi64.exe`_

---

# 6. Design implementation - ChatGPT slop:
## 6.1 CLI-Based Attacker Machine

```text
No GUI installed
```

### Reason

* Lower resource usage
* Faster execution
* Real-world Red Team practice

---

## 6.2 GUI Usage Strategy

```text
Kali VM → Collector
Local Machine → Analysis
```

Example:

* BloodHound collection → Kali
* BloodHound GUI → Local system

---

## 6.3 Avoided Tools

### Mythic C2

Not installed due to:

* Heavy Docker dependency
* High resource consumption

---

# 7. Final State

After configuration:

```text
✔ Kali VM deployed successfully
✔ Marketplace issues resolved
✔ SSH access configured
✔ Terminal issues fixed
✔ DNS and hostname configured
✔ Tools installed via script
✔ Organized attacker environment
```

---

# 8. Network Architecture

```text
10.0.1.0/24 → Domain Controller
10.0.2.0/24 → Workstations
10.0.3.0/24 → Kali Attacker
```

---

# 9. Key Learnings

1. Marketplace images require both agreement and plan
2. Terraform state must remain consistent
3. Minimal images require manual configuration
4. DNS is the backbone of Active Directory attacks
5. CLI-based attacker machines are more efficient than GUI-based ones
6. Tool installation should be modular, not monolithic

---
