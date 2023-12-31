variable "VULTR_API_KEY" {}

variable "domain" {}

variable "region" {
  type        = string
  description = "The default region to deploy to."
  default     = "ewr"
}

variable "firewall_rules" {
  type        = list(map(string))
  description = "The list of firewall rules to create."
}

variable "instances" {
  type        = list(map(string))
  description = "The list of instances to create."
}

variable "authorized_keys" {
  type        = list(string)
  description = "SSH key in list form to add to the root user."
  default     = []
}