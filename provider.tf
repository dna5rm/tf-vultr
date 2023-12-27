terraform {
  backend "s3" {}
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
  }
}

provider "vultr" {
  api_key     = var.VULTR_API_KEY
  rate_limit  = 700
  retry_limit = 3
}
