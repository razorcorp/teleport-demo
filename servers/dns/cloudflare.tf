# Project: cloudflare-configuration
# Created by: Praveen Premaratne
# Created on: 21/12/2024 23:08

variable "zone" {
  type        = string
  description = "Zone name"
}

variable "records" {
  description = "List of DNS records"
  type = list(object({
    type    = string
    name    = string
    value   = string
    proxy   = bool
    ttl     = number
    comment = string
  }))
}

data "cloudflare_zones" "zone" {
  filter {
    name        = var.zone
    lookup_type = "exact"
  }
}

resource "cloudflare_record" "record" {
  for_each = {
    for record in var.records : record.name => record
  }
  zone_id = data.cloudflare_zones.zone.zones[0].id

  type    = each.value.type
  name    = each.value.name
  content = each.value.value
  ttl     = each.value.ttl
  proxied = each.value.proxy
  comment = each.value.comment

}
