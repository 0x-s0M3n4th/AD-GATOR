#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "[+] Updating system..."
sudo apt update -y

echo "[+] Installing base packages and Kali repository tools..."
sudo apt install -y \
  nmap \
  smbclient \
  enum4linux \
  ldap-utils \
  dnsutils \
  netcat-openbsd \
  proxychains4 \
  freerdp3-x11 \
  git \
  curl \
  wget \
  unzip \
  python3-pip \
  python3-venv \
  pipx \
  golang \
  ruby-full \
  chisel \
  ligolo-ng \
  jq

echo "[+] Installing Metasploit..."
sudo apt install -y metasploit-framework

echo "[+] Setting up pipx..."
# pipx is now installed via apt to avoid PEP 668 externally-managed errors
pipx ensurepath

# Ensure ~/.local/bin is in the PATH for the current script execution
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
# Added '|| true' or directory check to prevent set -e from killing the script if it already exists
if [ ! -d "enum4linux-ng" ]; then
  git clone https://github.com/cddmp/enum4linux-ng.git
else
  echo "[-] enum4linux-ng already exists, skipping..."
fi

echo "[+] Cloning SharpHound..."
if [ ! -d "SharpHound" ]; then
  git clone https://github.com/BloodHoundAD/SharpHound.git
else
  echo "[-] SharpHound already exists, skipping..."
fi

# =========================
# Binary tools
# =========================
# Note: Chisel and Ligolo-ng are now handled cleanly via apt in the block above.
# They will be automatically available in your PATH.

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
# Environment configuration
# =========================

echo "[+] Ensuring ~/.local/bin is in PATH for future sessions..."
if ! grep -q "$HOME/.local/bin" ~/.zshrc; then
  echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
fi

if ! grep -q "$HOME/.local/bin" ~/.bashrc; then
  echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
fi

# =========================
# Final
# =========================

echo "[+] Cleaning up..."
cd ~

echo "[+] Setup complete!"
echo "[+] Tools directory: ~/tools"
echo "[+] Note: Chisel and Ligolo-ng were installed via apt and are ready to use."
echo "[+] Restart your terminal or run: source ~/.zshrc":w

