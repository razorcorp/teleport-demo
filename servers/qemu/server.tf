variable "dc" {
  type = string
}

variable "hostname" {
  type = string
}

variable "resources" {
  type = object({
    cpu    = number
    memory = number
    swap   = number
  })
  description = "Container resource options"
  default = {
    cpu    = 1
    memory = 1024
    swap   = 512
  }
}

variable "networking" {
  type = object({
    bridge  = string
    ip_addr = string
    cidr    = number
    gateway = string
  })
  description = "Container network configuration"
}

variable "root_disk" {
  type = object({
    location = string
    size_gb  = string
  })
}

variable "ssh_public_keys" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "features" {
  type = object({
    nesting = bool
  })
  default = {
    nesting = false
  }
}

resource "proxmox_vm_qemu" "server" {
  target_node = var.dc
  name        = var.hostname

  start        = true
  onboot       = true
  unprivileged = true
  protection   = false


  cores  = var.resources.cpu
  memory = var.resources.memory
  swap   = var.resources.swap

  ssh_public_keys = var.ssh_public_keys

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/ubuntu-20.04.2-live-server-amd64.iso"
        }
      }
    }
  }

  rootfs {
    storage = var.root_disk.location
    size    = "${var.root_disk.size_gb}G"
  }

  network {
    id       = 0
    firewall = false
    bridge   = var.networking.bridge
    model    = "e1000"
  }

  features {
    nesting = var.features.nesting
  }

  nameserver = "1.1.1.1 8.8.8.8"

  tags = length(var.tags) > 0 ? join(";", var.tags) : ""
}