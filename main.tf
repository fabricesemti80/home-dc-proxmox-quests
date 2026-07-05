# Keep Talos VMs in home-dc-kubernetes.

resource "proxmox_virtual_environment_container" "proxmox_pbs_0" {
  node_name   = "pve-0"
  vm_id       = 4016
  description = "Proxmox Backup Server candidate. Managed by Terraform."
  tags        = ["dns", "pbs", "terraform"]

  started      = true
  unprivileged = true

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
    swap      = 512
  }

  disk {
    datastore_id = "local"
    size         = 16
  }

  features {
    nesting = true
  }

  initialization {
    hostname = "proxmox-pbs-0"

    dns {
      servers = ["10.0.40.1"]
    }

    ip_config {
      ipv4 {
        address = "10.0.40.16/24"
        gateway = "10.0.40.1"
      }
    }

    user_account {
      keys = var.root_ssh_public_keys
    }
  }

  network_interface {
    name    = "veth0"
    bridge  = "vmbr0"
    vlan_id = 40
  }

  operating_system {
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
    type             = "debian"
  }

  startup {
    order      = "2"
    up_delay   = "30"
    down_delay = "30"
  }
}
