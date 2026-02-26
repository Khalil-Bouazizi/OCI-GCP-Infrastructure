locals {
	instances_with_region = {
		for name, instance in var.instances :
		name => merge(instance, {
			region = regexreplace(instance.zone, "-[a-z]$", "")
		})
	}
}

module "instance_template" {
	source = "./submodules/instance_template"

	for_each = local.instances_with_region

	project_id             = var.project_id
	region                 = each.value.region
	name_prefix            = each.key
	machine_type           = each.value.machine_type
	subnetwork             = each.value.subnetwork
	source_image_project   = each.value.source_image_project
	source_image_family    = each.value.source_image_family
	disk_size_gb           = each.value.disk_size_gb
	network_tags           = each.value.network_tags
	metadata               = each.value.metadata
	assign_public_ip       = each.value.assign_public_ip
	service_account_email  = each.value.service_account_email
	service_account_scopes = each.value.service_account_scopes
}

module "compute_instance" {
	source = "./submodules/compute_instance"

	for_each = local.instances_with_region

	project_id        = var.project_id
	zone              = each.value.zone
	hostname          = each.key
	instance_template = module.instance_template[each.key].self_link_unique

	depends_on = [
		module.instance_template
	]
}