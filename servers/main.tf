variable "dc" {
  type    = string
  default = "orion"
}

variable "ssh_public_keys" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}


module "dns-records" {
  source = "./dns"
  zone   = "razorcorp.dev"
  records = [
    {
      type    = "A"
      name    = "teleport"
      value   = "172.18.100.60"
      proxy   = false
      ttl     = 1
      comment = null
    },
    {
      type    = "CNAME"
      name    = "grafana.teleport"
      value   = "teleport.razorcorp.dev"
      proxy   = false
      ttl     = 1
      comment = null
    },
    {
      type    = "A"
      name    = "test-grafana"
      value   = "172.18.100.61"
      proxy   = false
      ttl     = 1
      comment = null
    }
  ]
}

module "teleport-server" {
  source = "./lxc"

  dc       = var.dc
  hostname = "teleport-server"
  networking = {
    bridge  = "vmbr0"
    ip_addr = "172.18.100.60"
    cidr    = 24
    gateway = "172.18.100.1"
  }

  root_disk = {
    size_gb  = 50
    location = "local-zfs"
  }

  ssh_public_keys = var.ssh_public_keys
  tags            = concat(var.tags, ["teleport"])

}

module "test-server" {
  source = "./lxc"

  dc       = var.dc
  hostname = "test-server"
  networking = {
    bridge  = "vmbr0"
    ip_addr = "172.18.100.61"
    cidr    = 24
    gateway = "172.18.100.1"
  }

  root_disk = {
    size_gb  = 15
    location = "local-zfs"
  }

  resources = {
    cpu    = 1
    memory = 512
    swap   = 512
  }

  ssh_public_keys = var.ssh_public_keys
  tags            = concat(var.tags, ["server-access"])

}

# module "minikube" {
#   source = "./lxc"

#   dc       = var.dc
#   hostname = "minikube"
#   networking = {
#     bridge  = "vmbr0"
#     ip_addr = "172.18.100.62"
#     cidr    = 24
#     gateway = "172.18.100.1"
#   }

#   root_disk = {
#     size_gb  = 20
#     location = "local-zfs"
#   }

#   resources = {
#     cpu    = 2
#     memory = 2048
#     swap   = 512
#   }

#   features = {
#     nesting = true
#   }

#   ssh_public_keys = var.ssh_public_keys
#   tags            = concat(var.tags, ["kubernetes"])

# }