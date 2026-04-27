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
