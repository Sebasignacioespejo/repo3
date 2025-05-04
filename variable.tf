variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "gogs-rg"
}

variable "vm_admin_user" {
  type = string
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "mysql_user" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}
