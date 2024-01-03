variable "VULTR_API_KEY" {}

variable "dns_zones" {
  type    = map(any)
  default = {}
}

variable "vpc_region_cidr" {
  type = map(string)
  default = {
    "atl" = "10.65.0.0/16" # Atlanta
    "ewr" = "10.71.0.0/16" # New Jersey
  }
}

# Do not include the owner account!
# Make sure API access is enabled for the account.
variable "vultr_users" {
  type    = map(any)
  default = {}
}