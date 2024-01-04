# Terraform - Vultr Resource Provisioning
## This file contains the main resources for the Vultr Cloud Provider

/**********************************************************************************************************************
 * Data Sources - These are used to get/validate information from Vultr
 *********************************************************************************************************************/

data "http" "regions" {
  url = "https://api.vultr.com/v2/regions"
}

data "http" "compute_plans" {
  url = "https://api.vultr.com/v2/plans"
}

data "http" "compute_os" {
  url = "https://api.vultr.com/v2/os"
}

/**********************************************************************************************************************
 * Locals - These are used to create maps and lists of data to be used in the resources
 *********************************************************************************************************************/

locals {
  # Create a map of OS names to OS IDs
  os_name_to_id = {
    for os in jsondecode(data.http.compute_os.response_body)["os"] : os["name"] => os["id"]
  }

  # Create a list of valid plans by ID
  plans = {
    for plan in jsondecode(data.http.compute_plans.response_body)["plans"] : plan["id"] => plan["id"]
  }

  # Create a map of 3-letter region id to City Names
  city_to_id = {
    for region in jsondecode(data.http.regions.response_body)["regions"] : region["city"] => region["id"]
  }

  # Create a map of firewall rules
  fwrules = [
    for rule in var.firewall_rules : {
      key         = index(var.firewall_rules, rule)
      ip_type     = length(split(":", try(rule["cidr"], ""))) > 1 ? "v6" : "v4"
      protocol    = rule["protocol"]
      subnet      = try(split("/", rule["cidr"])[0], "0.0.0.0")
      subnet_size = try(split("/", rule["cidr"])[1], 0)
      port        = try(rule["port"], null)
      notes       = try(rule["notes"], null)
    }
  ]
}

/**********************************************************************************************************************
 * Firewall Groups and Rules
 *********************************************************************************************************************/

# Create the firewall group
resource "vultr_firewall_group" "fwg" {
  description = join("-", ["tf", terraform.workspace])
}

# Create the firewall rules
resource "vultr_firewall_rule" "fwr" {
  for_each          = { for rule in local.fwrules : rule.key => rule }
  firewall_group_id = vultr_firewall_group.fwg.id

  ip_type     = each.value.ip_type
  protocol    = each.value.protocol
  subnet      = each.value.subnet
  subnet_size = each.value.subnet_size
  port        = each.value.port
  notes       = each.value.notes
}

/**********************************************************************************************************************
 * Root SSH Keys
 *********************************************************************************************************************/

# Create the root ssh key from a list of keys
resource "vultr_ssh_key" "ssh_key" {
  count = length(var.authorized_keys)

  name    = join("-", ["tf", terraform.workspace, count.index])
  ssh_key = var.authorized_keys[count.index]
}

/**********************************************************************************************************************
 * Instances
 *********************************************************************************************************************/

# Create the startup script
resource "vultr_startup_script" "startup_script" {
  count = length(var.instances)

  # Create a startup script for each instance
  name   = join("-", ["tf", try(var.instances[count.index].label, join("-", [terraform.workspace, count.index]))])
  script = filebase64(fileexists("scripts/startup_${try(number(var.instances[count.index].os), lookup(local.os_name_to_id, var.instances[count.index].os_name, null))}.sh") ? "scripts/startup_${try(number(var.instances[count.index].os), lookup(local.os_name_to_id, var.instances[count.index].os_name, null))}.sh" : "scripts/startup.sh")
}

# Create a persistent block storage volume for each instance
resource "vultr_block_storage" "block_storage" {
  count = length(vultr_instance.compute)

  label                = try(var.instances[count.index].label, join("-", ["tf", terraform.workspace, count.index]))
  region               = try(lookup(local.city_to_id, var.instances[count.index].city, null), var.region)
  size_gb              = try(var.instances[count.index].block_storage_size, 40)
  attached_to_instance = vultr_instance.compute[count.index].id
  block_type           = "storage_opt" #"high_perf"
  live                 = true
}

# Create the instances
resource "vultr_instance" "compute" {
  count = length(var.instances)

  label       = try(var.instances[count.index].label, join("-", ["tf", terraform.workspace, count.index]))
  hostname    = try(join(".", [try(var.instances[count.index].label, join("-", ["tf", terraform.workspace, count.index])), try(var.domain, "guest")]))
  region      = try(lookup(local.city_to_id, var.instances[count.index].city, null), var.region)
  plan        = try(lookup(local.plans, var.instances[count.index].plan, null), var.instances[count.index].plan)
  os_id       = try(number(var.instances[count.index].os), lookup(local.os_name_to_id, var.instances[count.index].os_name, null))
  enable_ipv6 = try(var.instances[count.index].enable_ipv6, true)
  ssh_key_ids = try([for key in vultr_ssh_key.ssh_key : key.id], null)
  script_id   = vultr_startup_script.startup_script[count.index].id
  tags        = ["terraform", terraform.workspace]

  # Use the firewall group id
  firewall_group_id = vultr_firewall_group.fwg.id
  vpc2_ids          = try(var.instances[count.index].vpc2_ids, [])
}

/**********************************************************************************************************************
 * DNS Records
 *********************************************************************************************************************/

resource "vultr_dns_record" "forward_v4records" {
  count  = length(vultr_instance.compute)
  domain = var.domain

  name = vultr_instance.compute[count.index].label
  type = "A"
  data = vultr_instance.compute[count.index].main_ip
  ttl  = 300
}

resource "vultr_dns_record" "forward_v6records" {
  count  = length(vultr_instance.compute)
  domain = var.domain

  name = vultr_instance.compute[count.index].label
  type = "AAAA"
  data = vultr_instance.compute[count.index].v6_main_ip
  ttl  = 300
}

resource "vultr_reverse_ipv4" "reverse_v4records" {
  count = length(vultr_instance.compute)

  instance_id = vultr_instance.compute[count.index].id
  ip          = vultr_instance.compute[count.index].main_ip
  reverse     = vultr_instance.compute[count.index].hostname
}

resource "vultr_reverse_ipv6" "reverse_v6records" {
  count = length(vultr_instance.compute)

  instance_id = vultr_instance.compute[count.index].id
  ip          = vultr_instance.compute[count.index].v6_main_ip
  reverse     = vultr_instance.compute[count.index].hostname
}