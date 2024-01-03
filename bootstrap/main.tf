/*
 * Vultr Account Bootstrap
 * This file contains the main resources for the Vultr Cloud Provider
 */

# Generate random passwords for users.
resource "random_password" "user" {
  count            = length(var.vultr_users)
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create Vultr users.
resource "vultr_user" "user" {
  count = length(var.vultr_users)

  name        = keys(var.vultr_users)[count.index]
  email       = var.vultr_users[keys(var.vultr_users)[count.index]].email
  password    = random_password.user[count.index].result
  api_enabled = try(var.vultr_users[keys(var.vultr_users)[count.index]].api_enabled, false)
  acl         = try(var.vultr_users[keys(var.vultr_users)[count.index]].acls, [])
}

# Create Network DNS Zones.
resource "vultr_dns_domain" "zone" {
  count  = length(var.dns_zones)
  domain = keys(var.dns_zones)[count.index]
}

locals {
  # Flatten the map of all zone records into a single list.
  zone_records = flatten([
    for zone in vultr_dns_domain.zone : [
      for record in var.dns_zones[zone.domain] : {
        zone   = zone.domain
        record = record
      }
    ]
  ])
}

# Create Network DNS Records.
resource "vultr_dns_record" "record" {
  count = length(local.zone_records)

  domain   = local.zone_records[count.index].zone
  name     = local.zone_records[count.index].record.name
  type     = local.zone_records[count.index].record.type
  data     = local.zone_records[count.index].record.data
  ttl      = try(local.zone_records[count.index].record.ttl, null)
  priority = try(local.zone_records[count.index].record.priority, null)
}