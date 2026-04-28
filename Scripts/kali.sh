#!/bin/bash

set -e

echo "[+] Updating system..."
sudo apt update -y

echo "[+] Installing base packages..."
sudo apt install -y \
  nmap \
  smbclient \
  enum4linux \
  ldap-utils \
  dnsutils \
  netcat-openbsd \
  proxychains4 \
  xfreerdp \
  git \
  curl \
  wget \
  unzip \
  python3-pip \
  python3-venv \
  golang \
  ruby-full

echo "[+] Installing Metasploit..."
sudo apt install -y metasploit-framework

echo "[+] Setting up pipx..."
python3 -m pip install --user pipx
python3 -m pipx ensurepath
export PATH=$PATH:$HOME/.local/bin

echo "[+] Creating tools directory..."
mkdir -p ~/tools
cd ~/tools

# =========================
# Python-based tools
# =========================

echo "[+] Installing Impacket..."
pipx install impacket

echo "[+] Installing NetExec (nxc)..."
pipx install git+https://github.com/Pennyw0rth/NetExec

echo "[+] Installing BloodHound collector..."
pipx install bloodhound

# =========================
# Git-based tools
# =========================

echo "[+] Cloning enum4linux-ng..."
git clone https://github.com/cddmp/enum4linux-ng.git

echo "[+] Cloning SharpHound..."
git clone https://github.com/BloodHoundAD/SharpHound.git

# =========================
# Binary tools
# =========================

echo "[+] Installing Chisel..."
wget https://github.com/jpillora/chisel/releases/latest/download/chisel_linux_amd64.gz
gunzip chisel_linux_amd64.gz
chmod +x chisel_linux_amd64
sudo mv chisel_linux_amd64 /usr/local/bin/chisel

echo "[+] Installing Ligolo-ng..."
wget https://github.com/nicocha30/ligolo-ng/releases/latest/download/ligolo-ng_linux_amd64.tar.gz
tar -xzf ligolo-ng_linux_amd64.tar.gz
chmod +x ligolo-ng
sudo mv ligolo-ng /usr/local/bin/ligolo-ng

echo "[+] Installing Sliver C2..."
curl https://sliver.sh/install | sudo bash

# =========================
# Mimikatz (download only)
# =========================

echo "[+] Downloading Mimikatz..."
mkdir -p ~/tools/mimikatz
wget https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip \
  -O ~/tools/mimikatz/mimikatz.zip

# =========================
# Final
# =========================

echo "[+] Cleaning up..."
cd ~

echo "[+] Setup complete!"
echo "[+] Tools directory: ~/tools"
echo "[+] Restart shell or run: source ~/.zshrc"
