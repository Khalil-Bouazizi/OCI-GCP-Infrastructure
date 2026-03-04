# GCP Infrastructure (Hub/Spoke with VPC Peering)

This stack creates:
- Existing-organization project (no folder creation by default)
- Optional GCS bucket for Terraform remote state
- Hub VPC (`10.0.0.0/24`) and Spoke-A VPC (`10.0.1.0/24`)
- Bidirectional VPC peering (Hub <-> Spoke-A)
- One VM in Hub only (`vm-hub`, internal `10.0.0.10`, ephemeral external IP)
- Firewall rules:
    - SSH (`tcp/22`) inbound to Hub VM from allowed CIDRs
    - East-west `tcp` and `icmp` between peered VPC CIDRs

## 1) Prerequisites

- Terraform >= 1.5
- GCP credentials configured (`gcloud auth application-default login`)
- Existing GCP Organization ID
- Billing account ID

## 2) Configuration

Edit [gcp-infra-values.auto.tfvars](gcp-infra-values.auto.tfvars):
- `organization_id`, `billing_account`, `project_id`
- `create_folder = false`
- `vpcs` and `instances` according to Hub/Spoke design
- `instances[*].ssh_public_key_path` (example `~/.ssh/id_rsa.pub`)

Do not hardcode SSH keys in Terraform files.

## 3) Deploy

From [gcp-infra](.):

```powershell
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

## 4) State Bucket Migration (Optional)

If `create_state_bucket = true`, migrate local state to GCS after first apply:

```powershell
terraform init -migrate-state -reconfigure -backend-config="bucket=<your_state_bucket_name>" -backend-config="prefix=gcp-infra/state"
```

Or run the generated output command: `terraform_backend_init_command`.

## 5) Module Layout

- Root orchestrator: [main.tf](main.tf)
- Network wrapper: [modules/network/main.tf](modules/network/main.tf)
    - [modules/network/submodules/vpc/main.tf](modules/network/submodules/vpc/main.tf)
    - [modules/network/submodules/subnets/main.tf](modules/network/submodules/subnets/main.tf)
    - [modules/network/submodules/routes/main.tf](modules/network/submodules/routes/main.tf)
    - [modules/network/submodules/firewall-rules/main.tf](modules/network/submodules/firewall-rules/main.tf)
- Compute wrapper: [modules/compute/main.tf](modules/compute/main.tf)
