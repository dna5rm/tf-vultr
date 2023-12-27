output "instance_v4_address" {
  value = vultr_instance.compute[*].main_ip
}