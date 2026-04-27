# Phase 4 – Active Directory Configuration (Terraform + Azure CLI Workflow)

## Objective

Configure a complete Active Directory (AD) environment on the Domain Controller using:

* PowerShell scripts (modular configuration)
* Terraform (script delivery via VM Extension)
* Azure CLI (execution control and validation)

This phase converts the deployed VM into a structured, enterprise-like AD environment.

---

# 1. Script Development (PowerShell Layer)

All configuration logic was first written as modular PowerShell scripts and stored in the repository under `Scripts/`.

## Core Scripts

* `bootstrap.ps1` → Initial setup and execution trigger
* `promote-dc.ps1` → Domain Controller promotion
* `post-config.ps1` → Master orchestration script
* `users.ps1` → User creation
* `groups.ps1` → Group configuration
* `service-accounts.ps1` → Service account setup
* `ou-structure.ps1` → Organizational Unit creation
* `move-objects.ps1` → Object placement
* `shares.ps1` → File share creation
* `gpo.ps1` → Group Policy configuration
* `adcs.ps1` → Certificate Services installation

_You can check the scripts from our `Scripts/` directory inside the repo._
These scripts were designed to:

* Be modular
* Be re-runnable (idempotent where possible)
* Reflect a realistic enterprise AD structure

---

# 2. Terraform Integration (compute.tf)

Terraform was used to reference and download scripts from the GitHub repository using Azure VM Custom Script Extension.

## Key Configuration

```hcl
resource "azurerm_virtual_machine_extension" "dc_bootstrap" {
  name                 = "dc-bootstrap"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [
      "https://raw.githubusercontent.com/<repo>/Scripts/bootstrap.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/promote-dc.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/post-config.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/users.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/groups.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/service-accounts.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/ou-structure.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/move-objects.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/shares.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/gpo.ps1",
      "https://raw.githubusercontent.com/<repo>/Scripts/adcs.ps1"
    ],
    commandToExecute = "powershell -ExecutionPolicy Bypass -File bootstrap.ps1"
  })
}
```

This ensured:

* Scripts are fetched dynamically from the repository
* Initial execution is triggered automatically

---

# 3. Script Execution Flow

The execution chain was:

```
bootstrap.ps1
   ↓
promote-dc.ps1
   ↓ (system reboot)
post-config.ps1
   ↓
(modular scripts execution)
```

### Important Observation

The Domain Controller promotion caused a system reboot, which interrupted the execution chain. As a result, `post-config.ps1` did not execute automatically.

---

# 4. Manual Execution Using Azure CLI

To complete the configuration, scripts were executed manually using Azure CLI.

## Execute Post Configuration

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "powershell -ExecutionPolicy Bypass -File C:\ADSetup\post-config.ps1"
```

This approach allowed:

* Controlled execution after reboot
* Iterative debugging without redeploying infrastructure

---

# 5. Configuration Applied

## Domain Details

* Domain Name: `kurukshetra.local`
* NetBIOS: `KURUKSHETRA`
* Domain Controller: `ad-gator-dc`

---

## Users

* arjuna
* bhima
* karna
* duryodhana
* krishna (Domain Admin)
* SQLService (Service Account)

---

## Organizational Units

```
Hastinapur
Indraprastha
Kurukshetra
Dwaraka

Sub-OUs:
Users
Servers
Workstations
ServiceAccounts
VulnerableMachines
SecurityTools
```

---

## Groups and Privileges

* krishna added to Domain Admins
* Default Domain Controllers group retained

---

## File Share

* Name: KurukshetraShare
* Path: C:\MahabharataShare

---

## Active Directory Certificate Services (ADCS)

* Role installed and configured
* Service: certsvc running

---

## Group Policies

* Kurukshetra-Lab-RelaxedSecurity
* Hastinapur-SecureBaseline
* Indraprastha-WorkstationPolicy

---

# 6. Validation Using Azure CLI

A consolidated validation command was used:

```powershell
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  systeminfo | findstr /B /C:\"Domain\"
  Get-Service NTDS,certsvc
  Import-Module ActiveDirectory
  Get-ADUser -Filter * | Select Name
  Get-ADOrganizationalUnit -Filter * | Select Name
  Get-ADGroupMember 'Domain Admins'
  Get-SmbShare
  Get-GPO -All
  "
```

## Validation Results

* Domain successfully configured
* AD DS and ADCS services running
* Users present
* OU structure created
* File share available
* GPOs applied

---

# 7. Internal Architecture (Mahabharata Mapping)

```
                        DOMAIN: kurukshetra.local
                                |
                        Domain Controller
                            (ad-gator-dc)
                                |
        ---------------------------------------------------------
        |                 |                 |                   |
   Hastinapur       Indraprastha      Kurukshetra          Dwaraka
   (Secure Zone)    (User Zone)       (Battle Zone)        (Strategic Zone)
        |                 |                 |                   |
   Servers, Tools     Users, Workstations  Vulnerable      High Privilege
                                         Machines         Components
                                |
                          Users and Accounts
        ---------------------------------------------------------
        |         |         |          |         |              |
     arjuna    bhima     karna   duryodhana   krishna     SQLService
                                              (Admin)    (Service Account)
                                |
                         Shared Resources
                                |
                     KurukshetraShare (File Share)
                                |
                        Certificate Authority
                               ADCS
                                |
                         Group Policy Layer
        ---------------------------------------------------------
        |                      |                              |
  Relaxed Security      Secure Baseline           Workstation Policy
```

This structure provides:

* Identity layer (users, groups)
* Resource layer (shares)
* Policy layer (GPO)
* Trust layer (ADCS)

---

# 8. Issues Encountered and Fixes

## 1. Post-Configuration Script Not Executed

**Issue:**

* `post-config.ps1` did not run automatically

**Cause:**

* Domain Controller promotion triggered a reboot
* Azure VM extension does not resume execution after reboot

**Fix:**

* Executed script manually using Azure CLI

---

## 2. Nested Folder Structure Not Loaded

**Issue:**

* Modules were not available on VM

**Cause:**

* Azure Custom Script Extension does not reliably preserve nested directories

**Fix:**

* Flattened script structure

---

## 3. Password Complexity Failure

**Issue:**

* User creation failed

**Cause:**

* Password did not meet AD complexity requirements

**Fix:**

* Standardized password format:

```
Str0ng@Pass123! # anything like this , i chose `MYpassword123#`
```

Applied across all scripts

---

## 5. Invalid PowerShell Cmdlet

**Issue:**

* `Get-GPLink` not recognized -> i wasn't aware about this silly `GPT` stuffs.

**Cause:**

* Cmdlet does not exist in GroupPolicy module

**Fix:**

* Replaced logic with direct `New-GPLink` usage

---

# 9. Final Outcome

* Fully functional Active Directory environment
* Enterprise-style OU and user structure
* Script-based configuration integrated with Terraform
* Azure CLI used for execution control and validation
* Reproducible and modular deployment
