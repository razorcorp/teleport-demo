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

resource "proxmox_lxc" "server" {
  target_node = var.dc
  ostemplate  = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"

  start        = true
  onboot       = true
  unprivileged = true
  protection   = false


  hostname = var.hostname
  cores    = var.resources.cpu
  memory   = var.resources.memory
  swap     = var.resources.swap

  ssh_public_keys = var.ssh_public_keys

  rootfs {
    storage = var.root_disk.location
    size    = "${var.root_disk.size_gb}G"
  }

  network {
    name   = "eth0"
    bridge = var.networking.bridge
    ip     = "${var.networking.ip_addr}/${var.networking.cidr}"
    gw     = var.networking.gateway
  }

  features {
    nesting = var.features.nesting
  }

  nameserver = "1.1.1.1 8.8.8.8"

  tags = length(var.tags) > 0 ? join(";", var.tags) : ""
}