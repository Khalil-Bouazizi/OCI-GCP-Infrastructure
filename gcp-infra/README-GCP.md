# GCP Infrastructure (Equivalent to OCI stack)

This folder creates, step by step:
- Project (without creating folder)
- Terraform state bucket (optional bootstrap)
- VPC network
- Public and private subnets
- Firewall rules
- Routes (public default, private default, private Google APIs route)
- Compute Engine instances in public/private subnet

## 1) Prerequisites

- Terraform >= 1.5
- GCP credentials configured (`gcloud auth application-default login`)
- Existing GCP Organization ID
- Billing account ID (if creating project)

## 2) Configure values

Edit [gcp-infra-values.auto.tfvars](gcp-infra-values.auto.tfvars):
- `organization_id`
- `billing_account`
- `project_id`
- `create_state_bucket`, `state_bucket_name`, `state_bucket_location`, `state_bucket_prefix`
- `instances[*].ssh_public_key_path` (for example `~/.ssh/id_rsa.pub`)

Do not hardcode SSH keys in Terraform files. The key is loaded from your local `.pub` file path.

Project-only mode is the default in this repository:
- `create_folder = false`
- `create_project = true`

If you want the project under an existing folder, set `folder_id`.

## 3) Deploy step by step

From [gcp-infra](.):

```powershell
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

After first apply, migrate local state to the new GCS backend bucket:

```powershell
terraform init -migrate-state -reconfigure -backend-config="bucket=<your_state_bucket_name>" -backend-config="prefix=gcp-infra/state"
```

You can also read the generated `terraform_backend_init_command` output and run it directly.

## 4) What maps from OCI to GCP

- OCI compartment -> GCP folder/project
- OCI VCN -> GCP VPC
- OCI public/private subnet -> GCP public/private subnet
- OCI route tables -> GCP routes
- OCI internet gateway -> GCP default internet gateway route
- OCI NAT gateway -> GCP Cloud NAT
- OCI service gateway -> GCP private Google APIs access route + Private Google Access
- OCI compute instance -> GCP Compute Engine instance

## 5) Module source (Terraform Registry via local wrappers)

Root [main.tf](main.tf) calls local wrappers:
- [modules/vpc/main.tf](modules/vpc/main.tf)
- [modules/compute/main.tf](modules/compute/main.tf)

Inside those wrapper files, the Terraform Registry modules are imported directly:
- `terraform-google-modules/network/google`
- `terraform-google-modules/cloud-router/google`
- `terraform-google-modules/vm/google//modules/compute_instance`

`version` is intentionally omitted in wrapper files, so Terraform installs the latest module release during `terraform init`.

If you want Git source instead, replace the same `source` values in [main.tf](main.tf) with your Git URLs.

After changing any module source/version:

```powershell
terraform init -upgrade
terraform plan
```
