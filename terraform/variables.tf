variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint."
}

variable "proxmox_insecure" {
  type        = bool
  description = "Allow self-signed Proxmox TLS certificates."
  default     = true
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username for ticket auth."
  default     = "root@pam"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password for ticket auth."
  sensitive   = true
}

variable "root_ssh_public_keys" {
  type        = list(string)
  description = "SSH public keys to install for root in managed guests."
  default     = []
}

variable "tailscale_oauth_client_id" {
  type        = string
  description = "Tailscale OAuth client ID for managing ACLs."
}

variable "tailscale_oauth_client_secret" {
  type        = string
  description = "Tailscale OAuth client secret for managing ACLs."
  sensitive   = true
}
