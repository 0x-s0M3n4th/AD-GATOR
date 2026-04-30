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

#### Linux:
```bash
az vm image terms accept \
  --publisher kali-linux \
  --offer kali \
  --plan kali-2026-1
```

#### Windows:
```powershell
az vm image terms accept `
  --publisher kali-linux `
  --offer kali `
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

#### Linux:
```bash
curl ifconfig.me
```
#### Windows:
```powershell
(Invoke-RestMethod -Uri "https://ifconfig.me")
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
# or
Get-Content "$env:USERPROFILE\.ssh\kali_azure.pub"
```

---

### Create terraform.tfvars
_Go into `terraform` directory:_

#### Linux:
```bash
# You can find this directory after cloning the repository
cd terraform/
nano terraform.tfvars
```

#### Windows:
```powershell
cd terraform/
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

#### Linux:

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "systeminfo | findstr /B /C:\"Domain\""
```

#### Windows:
```powershell
az vm run-command invoke `
  --resource-group ad-gator-rg `
  --name ad-gator-dc `
  --command-id RunPowerShellScript `
  --scripts 'systeminfo | findstr /B /C:"Domain"'
```

---

### Run AD Configuration

#### Linux:
```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "powershell -ExecutionPolicy Bypass -File C:\ADSetup\post-config.ps1"
```

##### Verification - Linux:
```bash
  az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts '
  Import-Module ActiveDirectory
  Get-ADUser -Filter * | Select Name
  Get-ADOrganizationalUnit -Filter * | Select Name
  Get-ADGroupMember "Domain Admins"
  Get-SmbShare
  Get-GPO -All
  '
```

#### Windows:
```powershell
az vm run-command invoke `
  --resource-group ad-gator-rg `
  --name ad-gator-dc `
  --command-id RunPowerShellScript `
  --scripts 'powershell -ExecutionPolicy Bypass -File C:\ADSetup\post-config.ps1'
```
##### Verification - windows:
```powershell
    az vm run-command invoke `
  --resource-group ad-gator-rg `
  --name ad-gator-dc `
  --command-id RunPowerShellScript `
  --scripts '
  Import-Module ActiveDirectory
  Get-ADUser -Filter * | Select Name
  Get-ADOrganizationalUnit -Filter * | Select Name
  Get-ADGroupMember "Domain Admins"
  Get-SmbShare
  Get-GPO -All
  '
```
_When i was testing on windows the verification didn't work, it was returning nothing. To test the verification go to `portal.azure.com` -> login -> scroll down and look for `Resource Groups` option -> Click that -> Select `ad-gator-rg` -> Inside that select `ad-gator-dc` option -> On the left pane scroll down and expand the `Operations` option -> Click on `Run command` -> Select the first option on the table `RunPowerShellScript` -> and then paste the following command i am providing :_
```powershell
  Import-Module ActiveDirectory
  Get-ADUser -Filter * | Select Name
  Get-ADOrganizationalUnit -Filter * | Select Name
  Get-ADGroupMember "Domain Admins"
  Get-SmbShare
  Get-GPO -All
```
_We can use the same path for different machines to run remote commands onto any machine without logging in directly._

---

### Join Workstation to Domain

#### Linux:
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
#### Windows:
```powershell
az vm run-command invoke `
  --resource-group ad-gator-rg `
  --name ad-gator-ws `
  --command-id RunPowerShellScript `
  --scripts '
  $pass = ConvertTo-SecureString "Password@123" -AsPlainText -Force
  $cred = New-Object System.Management.Automation.PSCredential("KURUKSHETRA\krishna", $pass)
  Add-Computer -DomainName "kurukshetra.local" -Credential $cred -Force
  '
```
_The domain joining script is not getting executed on windows for some reason, so go to your `azure portal` -> Navigate to the `ad-gator-rg` resource group -> Select `ad-gator-ws` -> Select the `Run command` option showed earlier -> Paste the following commands to join the domain:_

```powershell
$pass = ConvertTo-SecureString "Password@123" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential("KURUKSHETRA\krishna", $pass)
Add-Computer -DomainName "kurukshetra.local" -Credential $cred -Force
```

---

### Restart Workstation
#### For linux only(On windows az cli the following command is not working):
```bash
az vm restart --resource-group ad-gator-rg --name ad-gator-ws
```

##### Verification on linux(az cli):
```bash
    az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript `
  --scripts "Get-ADComputer -Filter * | Select Name"
```
_It will return `ad-gator-dc` and `ad-gator-ws`_

#### For windows :
- Go to `azure portal` -> select the resource group -> select `ad-gator-ws`
- You will see an `overview` page  -> Click on `restart` option

##### Verification on windows(az cli):

```powershell
  az vm run-command invoke `
  --resource-group ad-gator-rg `
  --name ad-gator-dc `
  --command-id RunPowerShellScript `
  --scripts "Get-ADComputer -Filter * | Select Name"
```
_It will return `ad-gator-dc` and `ad-gator-ws`_

### Moving our workstation to Indraprastha OU:

#### On linux:
```bash
    az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  Import-Module ActiveDirectory
  \$comp = Get-ADComputer ad-gator-ws
  Move-ADObject -Identity \$comp.DistinguishedName \
    -TargetPath 'OU=Workstations,OU=Indraprastha,DC=kurukshetra,DC=local'
  "
```
##### Verification:
```bash
  az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "
  Import-Module ActiveDirectory
  Get-ADComputer ad-gator-ws -Properties DistinguishedName |  Select Name, DistinguishedName
  "
```
#### On windows:
_az cli not working in this scenario too, we will utilize `azure portal's` `Run command option`_
- Open `portal.azure.com` -> scroll down and look for `Resource Groups` option -> Click that -> Select `ad-gator-rg` -> Inside that select `ad-gator-dc` option -> On the left pane scroll down and expand the `Operations` option -> Click on `Run command` -> Select the first option on the table `RunPowerShellScript` -> and then paste the following command i am providing :_

```powershell
Import-Module ActiveDirectory

$comp = Get-ADComputer -Identity "ad-gator-ws"

Move-ADObject `
  -Identity $comp.DistinguishedName `
  -TargetPath "OU=Workstations,OU=Indraprastha,DC=kurukshetra,DC=local"
```

##### Verification on azure portal:
```powershell
Import-Module ActiveDirectory
Get-ADComputer ad-gator-ws -Properties DistinguishedName |  Select Name, DistinguishedName
```

---

## Phase 6: Kali Attacker Machine Setup

### Connect via SSH

#### Linux:
```bash
ssh -i ~/.ssh/kali_azure kali@<KALI_PUBLIC_IP>
```

Windows:

```powershell
ssh -i C:\Users\$env:USERNAME\.ssh\kali_azure kali@<KALI_PUBLIC_IP>
```

---

### Fix Kali Environment (First Login)
_Don't manually write the commands, copy paste them -> fix the terminal then you can run normal commands manually._
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
_Native windows GUI_
```powershell
# This will open the native Windows GUI for Remote Desktop
cmdkey /generic:TERMSRV/<DC_IP> /user:"KURUKSHETRA\krishna" /pass:"Password@123"
mstsc /v:<DC_IP>

cmdkey /generic:TERMSRV/<WS_IP> /user:"KURUKSHETRA\krishna" /pass:"Password@123"
mstsc /v:<WS_IP>
```

---

### Debian / Ubuntu

```bash
sudo apt install freerdp3-x11 -y

xfreerdp3 /v:<DC_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
xfreerdp3 /v:<WS_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
```

---

### Arch Linux

```bash
sudo pacman -S freerdp

xfreerdp3 /v:<DC_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
xfreerdp3 /v:<WS_IP> /u:KURUKSHETRA\\krishna /p:'Password@123' /cert:ignore
```

==THANKS FOR USING GUYS!==
