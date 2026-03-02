resource "google_folder" "folder" {
	count = var.create_folder ? 1 : 0

	display_name = var.folder_name
	parent       = "organizations/${var.organization_id}"
}

resource "google_project" "project" {
	count = var.create_project ? 1 : 0

	project_id      = var.project_id
	name            = var.project_name
	billing_account = var.billing_account
	folder_id       = var.create_folder ? google_folder.folder[0].name : var.folder_id
	org_id          = (!var.create_folder && var.folder_id == null) ? var.organization_id : null

	auto_create_network = false
}

locals {
	effective_project_id = var.project_id
	sorted_vpc_keys      = sort(keys(var.vpcs))

	vpcs_resolved = {
		for name, vpc in var.vpcs :
		name => {
			index_resolved = coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name))

			cidr_block = coalesce(
				try(vpc.cidr_block, null),
				cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))
			)

			public_subnet_cidr = coalesce(
				try(vpc.public_subnet_cidr, null),
				cidrsubnet(
					coalesce(
						try(vpc.cidr_block, null),
						cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))
					),
					var.subnet_newbits,
					var.public_subnet_netnum
				)
			)

			private_subnet_cidr = coalesce(
				try(vpc.private_subnet_cidr, null),
				cidrsubnet(
					coalesce(
						try(vpc.cidr_block, null),
						cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))
					),
					var.subnet_newbits,
					var.private_subnet_netnum
				)
			)

			public_subnet_name        = coalesce(try(vpc.public_subnet_name, null), "${name}-public-subnet")
			private_subnet_name       = coalesce(try(vpc.private_subnet_name, null), "${name}-private-subnet")
			public_ingress_cidrs      = try(vpc.public_ingress_cidrs, ["0.0.0.0/0"])
			public_ingress_tcp_ports  = try(vpc.public_ingress_tcp_ports, [22])
			enable_private_googleapis = try(vpc.enable_private_googleapis, true)
			service_gateway_cidr      = try(vpc.service_gateway_cidr, "199.36.153.8/30")
		}
	}

	instances_resolved = {
		for name, instance in var.instances :
		name => {
			zone                   = coalesce(try(instance.zone, null), var.zone)
			machine_type           = try(instance.machine_type, "e2-micro")
			image                  = try(instance.image, "debian-cloud/debian-12")
			subnetwork             = lower(instance.subnet_type) == "public" ? format("projects/%s/regions/%s/subnetworks/%s", local.effective_project_id, var.region, local.vpcs_resolved[instance.vpc_key].public_subnet_name) : format("projects/%s/regions/%s/subnetworks/%s", local.effective_project_id, var.region, local.vpcs_resolved[instance.vpc_key].private_subnet_name)
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
}

module "network" {
	source = "./modules/network"

	for_each = local.vpcs_resolved

	project_id = local.effective_project_id
	region     = var.region
	vpc_name   = each.key
	cidr_block = each.value.cidr_block

	public_subnet_name  = each.value.public_subnet_name
	private_subnet_name = each.value.private_subnet_name
	public_subnet_cidr  = each.value.public_subnet_cidr
	private_subnet_cidr = each.value.private_subnet_cidr
	public_ingress_cidrs      = each.value.public_ingress_cidrs
	public_ingress_tcp_ports  = each.value.public_ingress_tcp_ports
	enable_private_googleapis = each.value.enable_private_googleapis
	service_gateway_cidr      = each.value.service_gateway_cidr

	depends_on = [
		google_project.project,
		google_project_service.required
	]
}

module "compute" {
	source = "./modules/compute"

	project_id   = local.effective_project_id
	instances    = local.instances_resolved

	depends_on = [
		module.network
	]
}

module "object_storage_bucket" {
	source = "./modules/object-storage-bucket"
	count  = var.create_state_bucket ? 1 : 0

	name       = coalesce(var.state_bucket_name, "${local.effective_project_id}-tfstate")
	project_id = local.effective_project_id
	location   = var.state_bucket_location

	labels = {
		purpose     = "terraform-state"
		environment = "shared"
	}

	depends_on = [
		google_project.project,
		google_project_service.required
	]
}
