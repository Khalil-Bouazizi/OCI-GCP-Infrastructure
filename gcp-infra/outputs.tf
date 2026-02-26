output "folder_name" {
	description = "Created folder resource name when create_folder is true."
	value       = var.create_folder ? google_folder.folder[0].name : var.folder_id
}

output "project_id" {
	description = "Project ID where resources are created."
	value       = local.effective_project_id
}

output "vpc_self_links" {
	description = "VPC self links by VPC key."
	value = {
		for name, network_module in module.network :
		name => network_module.vpc_self_link
	}
}

output "public_subnet_self_links" {
	description = "Public subnet self links by VPC key."
	value = {
		for name, network_module in module.network :
		name => network_module.public_subnet_self_link
	}
}

output "private_subnet_self_links" {
	description = "Private subnet self links by VPC key."
	value = {
		for name, network_module in module.network :
		name => network_module.private_subnet_self_link
	}
}

output "instance_ids" {
	description = "Compute module outputs by instance key."
	value       = module.compute.instances
}
