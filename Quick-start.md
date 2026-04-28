# Quick Start Guide – AD-GATOR Lab Deployment

## Prerequisites

1. Install Terraform
```bash
suco pacman -S terraform
# verification
terraform -V
```
_Windows installation_
```powershell
winget install HashiCorp.Terraform
# verification 
terraform -version
```
_Debain installation_
```bash
# step 1
sudo apt update && sudo apt install -y gnupg software-properties-common curl

# step 2
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# if apt-key fails
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# step 3
sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# step 4
sudo apt update

# step 5
sudo apt install terraform -y
```


2. Install Azure CLI
```bash
sudo pacman -S azure-cli
# verification
az version
```
_Windows installation_
```powershell
winget install Microsoft.AzureCLI
# verification
az version
```
_Debian installation_
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az version
```

3. Have an active Azure subscription

---

## 1. Authenticate with Azure

Login to your Azure account:

```bash
az login
```

Verify the active subscription:

```bash
az account show
```

---

## 2. Clone the Repository

```bash
git clone https://github.com/0x-s0M3n4th/AD-GATOR.git
cd AD-GATOR
```

---

_Before hand perform this commands to get your public ip:_
```bash
curl ifconfig.me
# copy the ipv4 value, make sure you are connected to a wifi, not mobile hotspot
```

## 3. Configure Variables

Create the `terraform.tfvars` file inside `/terraform` folder and provide:

```text
- admin_password
- public_ip (your machine’s IP for RDP/SSH access)
- kali_ssh_public_key
```

---

## 4. Generate SSH Key (for Kali)

On your local machine:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/kali_azure
```

Copy the public key:

```bash
cat ~/.ssh/kali_azure.pub
```

Paste it into:

```text
terraform.tfvars → kali_ssh_public_key = ""
```

---

## 5. Initialize Terraform

```bash
terraform init
```

---

## 6. Plan Deployment

```bash
terraform plan
```

---

## 7. Apply Infrastructure

```bash
terraform apply
```

---

## 8. Wait for Provisioning

Important:

```text
Wait ~5–10 minutes after apply completes
```

Reason:

* AD DS installation runs via VM extension
* Domain setup is asynchronous

---

## 9. Verify Domain Controller

Run:

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-dc \
  --command-id RunPowerShellScript \
  --scripts "systeminfo | findstr /B /C:\"Domain\""
```

Expected:

```text
Domain: kurukshetra.local
```

---

## 10. Domain Join Workstation

Execute via Azure CLI:

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

Then restart:

```bash
az vm restart --resource-group ad-gator-rg --name ad-gator-ws
```

---

## 11. Verify Domain Join

```bash
az vm run-command invoke \
  --resource-group ad-gator-rg \
  --name ad-gator-ws \
  --command-id RunPowerShellScript \
  --scripts "systeminfo | findstr /B /C:\"Domain\""
```

Expected:

```text
Domain: kurukshetra.local
```

---

## 12. Connect to Kali Machine

```bash
ssh -i ~/.ssh/kali_azure kali@<public-ip>
```

---

## 13. Fix Kali Environment (First Login Only) -> paste the commands don't type them manually

Run:

```bash
export TERM=xterm
cp /etc/skel/.zshrc ~/.zshrc
echo 'export TERM=xterm' >> ~/.zshrc
```

---

## 14. Install Attacker Toolset

Download and run your setup script -> inside the kali vm:

```bash
wget https://raw.githubusercontent.com/AD-GATOR/main/Scripts/kali.sh
chmod +x kali.sh
./kali.sh
```

---

## 15. Verify Tools

```bash
nmap --version
nxc --version
impacket-smbclient
bloodhound-python -h
```

---

## Final State

After completing all steps:

```text
✔ Domain Controller deployed
✔ Active Directory configured
✔ Workstation domain joined
✔ Kali attacker machine ready
✔ Red Team tools installed
```

---

## Notes

* DNS must always point to Domain Controller (`10.0.1.10`)
* Use domain users (e.g., krishna) for authentication, not azureuser
* Kali is CLI-based; GUI tools should be run locally

---

End of Quick Start Guide

