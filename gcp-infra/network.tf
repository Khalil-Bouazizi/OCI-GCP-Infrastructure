locals {
	sorted_vpc_keys = sort(keys(var.vpcs))

	vpcs_resolved = {
		for name, vpc in var.vpcs :
		name => {
			index_resolved = coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name))
			subnet_type    = lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private"))

			cidr_block = coalesce(
				try(vpc.cidr_block, null),
				cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))
			)

			subnet_cidr = coalesce(
				try(vpc.subnet_cidr, null),
				try(vpc.subnet_type, null) == "public" ? try(vpc.public_subnet_cidr, null) : null,
				try(vpc.subnet_type, null) == "private" ? try(vpc.private_subnet_cidr, null) : null,
				cidrsubnet(
					coalesce(
						try(vpc.cidr_block, null),
						cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))
					),
					var.subnet_newbits,
					lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "public" ? var.public_subnet_netnum : var.private_subnet_netnum
				)
			)

			subnet_name = coalesce(
				try(vpc.subnet_name, null),
				lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "public" ? try(vpc.public_subnet_name, null) : null,
				lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "private" ? try(vpc.private_subnet_name, null) : null,
				"${name}-${lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private"))}-subnet"
			)

			public_subnet_name        = lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "public" ? coalesce(try(vpc.subnet_name, null), try(vpc.public_subnet_name, null), "${name}-public-subnet") : null
			private_subnet_name       = lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "private" ? coalesce(try(vpc.subnet_name, null), try(vpc.private_subnet_name, null), "${name}-private-subnet") : null
			public_subnet_cidr        = lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "public" ? coalesce(try(vpc.subnet_cidr, null), try(vpc.public_subnet_cidr, null), cidrsubnet(coalesce(try(vpc.cidr_block, null), cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))), var.subnet_newbits, var.public_subnet_netnum)) : null
			private_subnet_cidr       = lower(try(vpc.subnet_type, name == var.hub_vpc_key ? "public" : "private")) == "private" ? coalesce(try(vpc.subnet_cidr, null), try(vpc.private_subnet_cidr, null), cidrsubnet(coalesce(try(vpc.cidr_block, null), cidrsubnet(var.network_supernet_cidr, var.vpc_newbits, coalesce(try(vpc.vpc_index, null), index(local.sorted_vpc_keys, name)))), var.subnet_newbits, var.private_subnet_netnum)) : null
			public_ingress_cidrs      = try(vpc.public_ingress_cidrs, ["0.0.0.0/0"])
			public_ingress_tcp_ports  = try(vpc.public_ingress_tcp_ports, [22])
			enable_private_googleapis = try(vpc.enable_private_googleapis, true)
		}
	}
}

module "vpc" {
	source = "terraform-google-modules/network/google//modules/vpc"

	for_each = local.vpcs_resolved

	project_id   = var.project_id
	network_name = each.key
	routing_mode = "REGIONAL"

	depends_on = [
		google_project.project,
		google_project_service.required
	]
}

module "subnets" {
	source = "terraform-google-modules/network/google//modules/subnets"

	for_each = local.vpcs_resolved

	project_id   = var.project_id
	network_name = each.key

	subnets = [
		{
			subnet_name           = each.value.subnet_name
			subnet_ip             = each.value.subnet_cidr
			subnet_region         = var.region
			subnet_private_access = each.value.subnet_type == "private" && each.value.enable_private_googleapis ? "true" : "false"
			description           = each.value.subnet_type == "public" ? "Public subnet for internet reachable instances" : "Private subnet for internal workloads"
		}
	]

	depends_on = [
		module.vpc
	]
}

module "routes" {
	source = "terraform-google-modules/network/google//modules/routes"

	for_each = local.vpcs_resolved

	project_id   = var.project_id
	network_name = each.key
	routes = concat(
		[
			{
				name              = "${each.key}-${each.value.subnet_type}-default-route"
				description       = each.value.subnet_type == "public" ? "Default internet route for public instances" : "Default internet route for private instances"
				destination_range = "0.0.0.0/0"
				tags              = [each.value.subnet_type]
				next_hop_internet = true
				priority          = 1000
			}
		],
		each.value.subnet_type == "private" && each.value.enable_private_googleapis ? [
			{
				name              = "${each.key}-private-googleapis-route"
				description       = "Private Google APIs restricted VIP route"
				destination_range = "199.36.153.8/30" # goes to the Google API endpoint instead of normal internet routing.
				tags              = ["private"]
				next_hop_internet = true
				priority          = 900
			}
		] : []
	)

	depends_on = [
		module.subnets
	]
}

