# tf-vultr - Vultr Terraform Bootstrap

This Terraform configuration file provisions resources in the Vultr Cloud Provider. It sets up user accounts, dns zones and records.

## Prerequisites

Before using this Terraform configuration, make sure you have the following:

- Terraform installed on your machine
- Vultr Account API credentials
- AWS S3 Bucket, to store backend tfstate

## Quickstart

1. Clone this repository to your local machine.
2. Change to 'bootstrap' branch.
3. Create your backend config file: config.tfbackend
```bash
tee config.tfbackend <<EOF
access_key = "==[YOUR AWS ACCESS KEY]=="
secret_key = "==[YOUR AWS SECRET KEY]=="
region = "==[BUCKET REGION]=="
bucket = "==[BUCKET NAME]=="
encrypt = "true"
key = "vultr/terraform.tfstate"
workspace_key_prefix = "workspace"
EOF
```
4. Run `terraform init -backend-config=config.tfbackend` to initialize the working directory.
5. Create your tfstate file: terraform.tfvars
```bash
tee terraform.tfvars <<EOF
VULTR_API_KEY = "==[YOUR VULTR API KEY]=="
EOF
```
6. Create new `bootstrap.tfvars` file...
```bash
tee bootstrap.tfvars <<EOF
dns_zones = {
  "example1.local" = [
    {
      name = ""
      type = "A"
      data = "127.0.0.1"
    }
  ]
  "example2.local" = []
}
vultr_users = {
  "vultr user1" = {
    email       = "vuser1@example1.local"
    api_enabled = true
    acls = [
      "provisioning",
      "dns",
      "firewall"
    ]
  }
}
EOF
```
7. Run `terraform plan -var-file=bootstrap.tfvars` to see the execution plan.
8. Run `terraform apply -var-file=bootstrap.tfvars` to create the resources.
9. When you're done, run `terraform destroy -var-file=bootstrap.tfvars` to delete the resources.

## Configuration

The `main.tf` file contains the main resources for the Vultr Cloud Provider. It consists of the following sections:

- Data Sources: These are used to get and validate information from Vultr.
- Locals: These are used to create maps and lists of data to be used in the resources.
- Firewall Groups and Rules: Creates a firewall group and associated rules.
- Instances: Creates Vultr instances based on the provided configuration.
- DNS Records: Manages DNS records for the created instances.

## Handy/Extra Commands

### Vultr Regions
`jq -r '.regions[]|[.id, .city]|@tsv' <(curl --silent https://api.vultr.com/v2/regions)`

### Instance Settings
`jq -r '.os[]|[.id, .name]|@tsv' <(curl --silent https://api.vultr.com/v2/os)`

### Instance Plans
`jq -r '.plans[]|select(.monthly_cost < 20)|[.id, .vcpu_count, .ram, .monthly_cost]|@tsv' <(curl --silent https://api.vultr.com/v2/plans?type=vc2)`

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.
