terraform {
  backend "s3" {
    endpoints                   = { s3 = "https://api.minio.razorcorp.dev" }
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
    bucket                      = "terraform-state"
    key                         = "teleport/terraform.tfstate"
    region                      = "eu-west-2"
  }
}