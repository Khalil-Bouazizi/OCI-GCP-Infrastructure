output "folder_name" {
	description = "Created folder resource name when create_folder is true."
	value       = var.create_folder ? google_folder.folder[0].name : var.folder_id
}

output "project_id" {
	description = "Project ID where resources are created."
	value       = var.project_id
}

output "vpc_self_links" {
	description = "VPC self links by VPC key."
	value = {
		for name, vpc in local.vpcs_resolved :
		name => format("projects/%s/global/networks/%s", var.project_id, name)
	}
}

output "public_subnet_self_links" {
	description = "Public subnet self links by VPC key."
	value = {
		for name, vpc in local.vpcs_resolved :
		name => vpc.subnet_type == "public" ? format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, vpc.subnet_name) : null
	}
}

output "private_subnet_self_links" {
	description = "Private subnet self links by VPC key."
	value = {
		for name, vpc in local.vpcs_resolved :
		name => vpc.subnet_type == "private" ? format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, vpc.subnet_name) : null
	}
}

output "instance_ids" {
	description = "Instance keys by instance name."
	value = {
		for name in keys(local.instances_resolved) :
		name => name
	}
}

output "vpc_peering_names" {
	description = "Hub/Spoke VPC peering resource names."
	value = {
		hub_to_spoke = google_compute_network_peering.hub_to_spoke.name
		spoke_to_hub = google_compute_network_peering.spoke_to_hub.name
	}
}

output "terraform_state_bucket_name" {
	description = "GCS bucket used for Terraform remote state when create_state_bucket=true."
	value       = var.create_state_bucket ? module.object_storage_bucket[0].name : null
}

output "terraform_state_bucket_url" {
	description = "URL of the GCS bucket used for Terraform state."
	value       = var.create_state_bucket ? module.object_storage_bucket[0].url : null
}

output "terraform_backend_init_command" {
	description = "Run this command after initial apply to migrate local state to GCS backend."
	value = var.create_state_bucket ? format(
		"terraform init -migrate-state -reconfigure -backend-config=\"bucket=%s\" -backend-config=\"prefix=%s\"",
		module.object_storage_bucket[0].name,
		var.state_bucket_prefix
	) : null
}
