variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "ad-gator-rg"
}

variable "location" {
  description = "Azure region"
  default     = "Central India"
}
variable "my_ip" {
  description = "My public IP in CIDR format"
  type        = string
}
variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  description = "Windows admin password"
  sensitive   = true
}

# variables for Windows workstation
variable "ws_name" {
  default = "ad-gator-ws"
}

variable "ws_size" {
  default = "Standard_B2s"
}

# Kali variables
variable "kali_name" {
  default = "ad-gator-kali"
}

variable "kali_size" {
  default = "Standard_D2s_v3"
}

variable "kali_admin_username" {
  default = "kali"
}

variable "kali_ssh_public_key" {
  description = "SSH public key for Kali"
}
