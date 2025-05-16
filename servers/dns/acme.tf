# variable "domain" {
#   type = string
# }

# resource "acme_registration" "entity" {
#   email_address = "support@razorcorp.dev"
# }

# resource "acme_certificate" "certificate" {
#   account_key_pem = acme_registration.entity.account_key_pem
#   common_name     = var.domain

#   dns_challenge {
#     provider = "cloudflare"
#   }
# }

# data "template_file" "fullchain" {
#   template = "$${certificate}$${private_key}"

#   vars = {
#     certificate = acme_certificate.certificate.certificate_pem
#     private_key = acme_certificate.certificate.private_key_pem
#   }
# }