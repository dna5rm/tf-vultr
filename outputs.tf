# output all the instance attributes
output "instance" {
  value     = vultr_instance.compute[*]
  sensitive = true
}
