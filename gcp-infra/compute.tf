locals {
	instances_resolved = {
		for name, instance in var.instances :
		name => {
			zone                   = coalesce(try(instance.zone, null), var.zone)
			machine_type           = try(instance.machine_type, "e2-micro")
			image                  = try(instance.image, "debian-cloud/debian-12")
			subnetwork             = format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, local.vpcs_resolved[instance.vpc_key].subnet_name)
			assign_public_ip       = try(instance.assign_public_ip, true)
			disk_size_gb           = try(instance.disk_size_gb, 20)
			network_tags           = distinct(concat(try(instance.network_tags, []), [lower(instance.subnet_type)]))
			metadata               = merge(
				try(instance.metadata, {}),
				try(instance.ssh_public_key_path, null) != null ? {
					"ssh-keys" = format("%s:%s", try(instance.ssh_username, "ubuntu"), trimspace(file(pathexpand(instance.ssh_public_key_path))))
				} : {}
			)
			service_account_email  = try(instance.service_account_email, null)
			service_account_scopes = try(instance.service_account_scopes, ["https://www.googleapis.com/auth/cloud-platform"])
			source_image_project   = split("/", try(instance.image, "debian-cloud/debian-12"))[0]
			source_image_family    = split("/", try(instance.image, "debian-cloud/debian-12"))[1]
		}
	}

	instances_with_region = {
		for name, instance in local.instances_resolved :
		name => merge(instance, {
			region = regexreplace(instance.zone, "-[a-z]$", "")
		})
	}
}

module "instance_template" {
	source = "terraform-google-modules/vm/google//modules/instance_template"

	for_each = local.instances_with_region

	project_id             = var.project_id
	region                 = each.value.region
	name_prefix            = each.key
	machine_type           = each.value.machine_type
	subnetwork             = each.value.subnetwork
	source_image_project   = each.value.source_image_project
	source_image_family    = each.value.source_image_family
	disk_size_gb           = tostring(each.value.disk_size_gb)
	tags                   = each.value.network_tags
	metadata               = each.value.metadata
	access_config          = each.value.assign_public_ip ? [{ network_tier = "STANDARD" }] : []
	service_account        = each.value.service_account_email == null ? null : {
		email  = each.value.service_account_email
		scopes = toset(each.value.service_account_scopes)
	}

	depends_on = [
		module.subnets
	]
}

module "compute_instance" {
	source = "terraform-google-modules/vm/google//modules/compute_instance"

	for_each = local.instances_with_region

	project_id          = var.project_id
	zone                = each.value.zone
	hostname            = each.key
	instance_template   = module.instance_template[each.key].self_link_unique
	add_hostname_suffix = false
	num_instances       = 1

	depends_on = [
		module.instance_template
	]
}