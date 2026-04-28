# Quick Start Guide – AD-GATOR Lab Deployment

Welcome to the AD-GATOR deployment guide! Follow these steps chronologically to build your Active Directory lab in Azure.

---

## Phase 1: Install Prerequisites

### Option A: Windows (PowerShell)

```powershell
# Install Terraform
winget install HashiCorp.Terraform
terraform -version

# Install Azure CLI
winget install Microsoft.AzureCLI
az version
```

---

### Option B: Debian / Ubuntu

```bash
# Install Terraform
sudo apt update && sudo apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform -y

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify
terraform -version
az version
```

---

### Option C: Arch Linux

```bash
sudo pacman -Syu terraform azure-cli
terraform -version
az version
```

---

## Phase 2: Azure Authentication & Preparation

```bash
az login
az account show
```

---

### Fix Provider Registration Errors (if needed)

```bash
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Storage

az provider show --namespace Microsoft.Compute --query "registrationState"
```

---

### Accept Kali Marketplace Terms (REQUIRED)

```bash
az vm image terms accept \
  --publisher kali-linux \
  --offer kali \
  --plan kali-2026-1
```

---

## Phase 3: Configuration & Keys

```bash
git clone https://github.com/0x-s0M3n4th/AD-GATOR.git
cd AD-GATOR
```

---

### Get Your Public IP

```bash
curl ifconfig.me
```
_Or go to `https://whatismyipaddress.com/` to see your IPV4 address_

---

### Generate SSH Keys

#### Linux / Mac

```bash
ssh-keygen -t ed25519 -f ~/.ssh/kali_azure
cat ~/.ssh/kali_azure.pub
```

#### Windows (PowerShell)

```powershell
ssh-keygen -t ed25519 -f C:\Users\$env:USERNAME\.ssh\kali_azure
type C:\Users\$env:USERNAME\.ssh\kali_azure.pub
```

---

### Create terraform.tfvars
_Go into `terraform` directory:_
```bash
# You can find this directory after cloning the repository
cd terraform/

# for linux users:
nano terraform.tfvars

# for windows users
notepad terraform.tfvars

```

_Add the following variables and your respected values_

```hcl
admin_password = "YOUR_PASSWORD" # example: 'StrongPassw0rd@123!'
my_ip = "YOUR_PUBLIC_IP"
kali_ssh_public_key = "YOUR_PUBLIC_KEY"
```

---

## Phase 4: Deploy Infrastructure

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

Wait **5–10 minutes** after apply completes.

---

## Phase 5: Active Directory Setup

### Verify Domain Controller

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "systeminfo | findstr /B /C:\"Domain\""
```

---

### Run AD Configuration

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "powershell -ExecutionPolicy Bypass -File C:\ADSetup\post-config.ps1"
```

---

### Join Workstation to Domain

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

### Restart Workstation

```bash
az vm restart --resource-group ad-gator-rg --name ad-gator-ws
```

---

## Phase 6: Kali Attacker Machine Setup

### Connect via SSH

```bash
ssh -i ~/.ssh/kali_azure kali@<KALI_PUBLIC_IP>
```

Windows:

```powershell
ssh -i C:\Users\$env:USERNAME\.ssh\kali_azure kali@<KALI_PUBLIC_IP>
```

---

### Fix Kali Environment (First Login)

```bash
cp /etc/skel/.zshrc ~/.zshrc
echo 'export TERM=xterm' >> ~/.zshrc
source ~/.zshrc
echo 'source ~/.zshrc' > ~/.zprofile
```

---

### Install Tools

```bash
wget https://raw.githubusercontent.com/0x-s0M3n4th/AD-GATOR/main/Scripts/kali.sh
chmod +x kali.sh
./kali.sh
```

---

### Verify Tools

```bash
nmap --version
nxc --version
impacket-smbclient
bloodhound-python -h
```

---

## Phase 7: Optional RDP Verification

### Get VM IPs

```bash
az vm list-ip-addresses --resource-group ad-gator-rg -o table
```

---

### Windows (wfreerdp)

```powershell
winget install FreeRDP.FreeRDP

wfreerdp /v:<DC_IP> /u:KURUKSHETRA\krishna /p:Password@123 /cert:ignore
wfreerdp /v:<WS_IP> /u:KURUKSHETRA\krishna /p:Password@123 /cert:ignore
```

---

### Debian / Ubuntu

```bash
sudo apt install freerdp2-x11 -y

xfreerdp /v:<DC_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
xfreerdp /v:<WS_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
```

---

### Arch Linux

```bash
sudo pacman -S freerdp

xfreerdp /v:<DC_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
xfreerdp /v:<WS_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
```

---

## Final State

```
✔ Domain Controller deployed
✔ Active Directory configured
✔ Workstation domain joined
✔ Kali attacker machine ready
✔ Red Team tools installed
```

---

## Important Notes

- DNS must point to Domain Controller (10.0.1.10)
- Use domain users (krishna), not azureuser
- Kali is CLI-based; GUI tools should run locally
