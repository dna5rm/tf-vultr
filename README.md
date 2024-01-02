# tf-vultr - Vultr Terraform Scripts

This Terraform configuration file provisions resources in the Vultr Cloud Provider. It sets up firewall groups and rules, creates instances, and manages DNS records.

## Prerequisites

Before using this Terraform configuration, make sure you have the following:

- Terraform installed on your machine
- Vultr API credentials
- AWS S3 Bucket, to store backend tfstate

## Quickstart

1. Clone this repository to your local machine.
2. Create your backend config file: config.s3.tfbackend
```bash
tee config.s3.tfbackend <<EOF
access_key = "==[YOUR AWS ACCESS KEY]=="
secret_key = "==[YOUR AWS SECRET KEY]=="
region = "==[BUCKET REGION]=="
bucket = "==[BUCKET NAME]=="
encrypt = "true"
key = "terraform.tfstate"
workspace_key_prefix = "vultr"
EOF
```
3. Run `terraform init -backend-config=config.s3.tfbackend` to initialize the working directory.
4. Create your tfstate file: terraform.tfvars
```bash
tee terraform.tfvars <<EOF
VULTR_API_KEY = "==[YOUR VULTR API KEY]=="
EOF
```
4. Create new `instances.auto.tfvars` file...
```bash
tee instances.auto.tfvars <<EOF
domain = "domain.local"

firewall_rules = [
  { protocol = "icmp" },
  { protocol = "tcp", port = 22 },
  { cidr = "::/0", protocol = "tcp", port = 22 }
]

instances = [
  {
    plan    = "vc2-1c-1gb"
    os_name = "Alpine Linux x64"
    city    = "Atlanta"
  },
  {
    plan    = "vc2-1c-1gb"
    os_name = "Alpine Linux x64"
    city    = "New Jersey"
  }
]
EOF
```
4. Run `terraform plan` to see the execution plan.
5. Run `terraform apply` to create the resources.
6. When you're done, run `terraform destroy` to delete the resources.

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
