# Phase 1: Environment Setup & Initial Deployment

## Objective

Set up the local development environment and deploy the first Azure resource using Terraform.

This phase establishes the foundation for building a cloud-based Active Directory attack-defense lab.

---

## System Environment

* OS: Arch Linux (Hyprland) -> You can use any of your preference(make sure to read the doc/ use any AI for guide)
* Shell: Zsh/Bash
* Package Manager: pacman / yay

---

## Tools Installed

### 1. Terraform

Terraform is used for Infrastructure as Code (IaC), enabling automated provisioning of Azure resources.

#### Installation

```bash
sudo pacman -S terraform
```

#### Verification

```bash
terraform -v
```

Expected Output:

```bash
Terraform v1.x.x
```

---

### 2. Azure CLI

Azure CLI is used to authenticate and interact with Microsoft Azure services.

#### Installation

```bash
sudo pacman -S azure-cli
```

#### Verification

```bash
az version
```

---

## Azure Authentication

### Login

```bash
az login
```

* Opens browser for authentication

---

### Verify Account

```bash
az account show
```

#### Output (example):

```json
{
  "name": "Azure for Students",
  "state": "Enabled",
  "user": {
    "name": "your-email"
  }
}
```

---

### Set Subscription(if already not set)
_If it's already set , you will notice it on the output of `az account Show`_

```bash
az account list --output table # shows the list of accounts 
az account set --subscription "Azure for Students"
```

---

## Project Structure Initialization
- Create one Github repository on your profile, i named it as `AD-GATOR`(as it's my own personal project).
- Then create one PAT(Personal Access Token), **Steps to create below :**
    1. Go to your profile settings -> Developer settings
    2. Click on `Personal Access Tokens` -> click on `Fine-grained tokens`
    3. Click the option `Generate a new token` -> Select `Repository Access` as `Only selected repositories` -> then select the repo you created at first, in my case it's `AD-GATOR`
    4. Click on `Add permissions` -> Search for `Contents` -> add it -> Modify the access as `Read and write`
    5. Then generate the token -> copy it and save it in a safer place.
    6. Clone the repository onto your machine -> then follow the next steps.

Created folders(inside the repository):

```bash
terraform/
Docs/
Scripts/
Diagrams/
```

**Commands:**
```bash
mkdir terraform
mkdir Docs
mkdir Scripts
mkdir Diagrams
```

---

## Terraform Configuration Files

Inside `terraform/` directory:
- Create these 4 files named as `provider.tf, main.tf, variables.tf, outputs.tf`

**Commands to create:**
```bash
touch provider.tf main.tf variables.tf outputs.tf
```
### A brief description of all the files and why they are being created:
1. **provider.tf :** It is the file where we tell `terraform` that we are working with `azure`
2. **variables.tf :** We are defining certain variables for our usecase which will make our code reusable.
3. **main.tf :** It contains the main infrastructure resources to create.
4. **outputs.tf :** Shows important values after deploying our infrastructure.

_Paste the following code snippets inside all the terraform files._

### provider.tf

```hcl
provider "azurerm" {
  features {}
}
```

---

### variables.tf

```hcl
variable "resource_group_name" {
  default = "ad-gator-rg"
}

variable "location" {
  default = "Central India"
}
```

---

### main.tf

```hcl
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
```

---

### outputs.tf

```hcl
output "rg_name" {
  value = azurerm_resource_group.rg.name
}
```

---

## Terraform Workflow

### Step 1: Initialize

```bash
terraform init
```

* Downloads required providers
* Initializes working directory

---

### Step 2: Plan

```bash
terraform plan
```

* Shows execution plan
* Example output:

```bash
+ azurerm_resource_group.rg
```

---

### Step 3: Apply

```bash
terraform apply
```

Confirm with:

```bash
yes
```

---

## Resource Verification

### Using Azure CLI

```bash
az group list --output table
```

Expected:

```bash
Name            Location
--------------- -------------
ad-gator-rg     Central India
```

---

## Cleanup

To avoid unnecessary cloud usage:

```bash
terraform destroy
```

---

## Questions i thought during the process:
1. How does `terraform` actually uses our `azure credentials` without even let us prompting for it? In simpler terms how does `terraform` integrates itself with `azure`?

**Answer :** When we ran `az login` for our authentication into the `azure portal` , at that time a token is being stored locally into the `~/.azure/` directory. After that when we defined our `provider.tf` and told `terraform` that we are going to use `azure` for this project, it does some things on the backend and these are the overview of it:
1. `terraform` checks for the stored credentials
2. Finds the Azure CLI login session.
3. Reuses that particular token.
4. Then it itself calls the `Azure API` on our behalf.

### BTS flow:

```Text
Terraform -> Azure Provider -> Azure CLI token -> Azure API -> Resources 
```
**Resources that may help further:**
[terraform-docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) 

## Key Learnings

* Basics of Infrastructure as Code using Terraform
* Azure authentication via CLI
* Resource provisioning workflow (initialize → plan → apply → destroy)
* Importance of verification and cleanup
* Structuring Terraform code using variables and outputs

---

## Notes

* Always verify resources after deployment
* Never leave unused resources running (cost risk)
* Use `terraform destroy` after testing
* Maintain proper documentation for each phase

---

