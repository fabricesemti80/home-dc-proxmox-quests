resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  node_name   = var.node_name
  vm_id       = var.vm_id
  description = var.description
  tags        = var.tags

  agent {
    enabled = true
  }

  dynamic "clone" {
    for_each = var.clone_vm_id == null ? [] : [1]
    content {
      vm_id     = var.clone_vm_id
      node_name = var.clone_node_name
      full      = true
    }
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
    floating  = var.memory_mb
  }

  disk {
    datastore_id = var.disk_datastore_id
    interface    = "scsi0"
    size         = var.disk_gb
  }

  initialization {
    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = var.ipv4
        gateway = var.gateway
      }
    }

    user_account {
      keys     = var.root_ssh_keys
      username = "root"
    }
  }

  network_device {
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    type = "l26"
  }
}
