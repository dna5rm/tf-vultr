# Output a map of usernames and IDs
output "vultr_users" {
  value     = { for user in vultr_user.user : user.name => { email = user.email, id = user.id, password = user.password } }
  sensitive = true
}

output "vultr_dns_zones" {
  value = { for zone in vultr_dns_domain.zone : zone.domain => zone.date_created }
}

#output "vultr_dns_records" {
#  value = { for record in vultr_dns_record.record : record.id => {
#    domain = record.domain,
#    name   = record.name,
#    type   = record.type,
#    data   = record.data
#    }
#  }
#}