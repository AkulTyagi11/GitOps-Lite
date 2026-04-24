# Step 3: Terraform Infrastructure

This folder provisions AWS infrastructure for GitOps Lite:

- 1 EC2 instance (Amazon Linux 2023)
- 1 security group allowing SSH (22) and HTTP (80)
- Outputs for public IP/DNS
- Optional CloudWatch CPU alarm

## Files

- `providers.tf`: Terraform + AWS provider setup
- `variables.tf`: Input variables
- `main.tf`: EC2, security group, CloudWatch alarm resources
- `outputs.tf`: Useful output values
- `terraform.tfvars.example`: Example variable values

## Prerequisites

1. AWS CLI configured (`aws configure`)
2. Terraform installed (`terraform -version`)
3. An existing AWS EC2 key pair (for SSH)

## Configure values

From this `terraform/` folder:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

- `key_name`: your AWS EC2 key pair name
- `ssh_cidr_blocks`: your IP in CIDR format (recommended), e.g. `203.0.113.10/32`

## Provision infrastructure

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

## Expected output

After `terraform apply`, you should see outputs similar to:

- `ec2_public_ip = "x.x.x.x"`
- `ec2_public_dns = "ec2-...amazonaws.com"`
- `ansible_inventory_line = "app_server ansible_host=x.x.x.x ansible_user=ec2-user"`

You can also query output values directly:

```bash
terraform output ec2_public_ip
terraform output -raw ec2_public_ip
```

## Clean up resources

```bash
terraform destroy -auto-approve
```

