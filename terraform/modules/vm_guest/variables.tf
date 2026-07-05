variable "name" {
  type = string
}

variable "node_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "description" {
  type    = string
  default = "Managed by Terraform."
}

variable "tags" {
  type    = list(string)
  default = ["terraform"]
}

variable "clone_vm_id" {
  type    = number
  default = null
}

variable "clone_node_name" {
  type    = string
  default = null
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "disk_datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "disk_gb" {
  type    = number
  default = 20
}

variable "ipv4" {
  type = string
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type    = list(string)
  default = []
}

variable "cloud_init_username" {
  type    = string
  default = null
}

variable "cloud_init_ssh_keys" {
  type    = list(string)
  default = []
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "vlan_id" {
  type    = number
  default = null
}
