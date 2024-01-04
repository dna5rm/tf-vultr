variable "VULTR_API_KEY" {}

variable "dns_zones" {
  type    = map(any)
  default = {}
}

variable "vpc_region_cidr" {
  type = map(any)
  default = {
    "atl" = {
      description = "Atlanta VPC"
      cidr        = "10.65.0.0/16"
    }
    "ewr" = {
      description = "New Jersey VPC"
      cidr        = "10.71.0.0/16"
    }
  }
}

# Do not include the owner account!
# Make sure API access is enabled for the account.
variable "vultr_users" {
  type    = map(any)
  default = {}
}