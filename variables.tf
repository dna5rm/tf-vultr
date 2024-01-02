variable "VULTR_API_KEY" {}

variable "domain" {
  type        = string
  description = "The vultr hosted domain to create the DNS records in."
  default     = "example.com"
}

variable "region" {
  type        = string
  description = "The default region to deploy to."
  default     = "ewr"
}

variable "firewall_rules" {
  type        = list(map(string))
  description = "The list of firewall rules to create."
  default     = []
}

variable "instances" {
  type        = list(map(string))
  description = "The list of instances to create."
  default    = []
}

variable "authorized_keys" {
  type        = list(string)
  description = "SSH key in list form to add to the root user."
  default     = []
}