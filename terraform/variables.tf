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
  type = string
}
