terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    # acme = {
    #   source  = "vancluever/acme"
    #   version = "2.32.0"
    # }

    # tls = {
    #   source  = "hashicorp/tls"
    #   version = "4.1.0"
    # }
  }
}

# provider "acme" {
#   # server_url = "https://acme-v02.api.letsencrypt.org/directory"
#   server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
# }
