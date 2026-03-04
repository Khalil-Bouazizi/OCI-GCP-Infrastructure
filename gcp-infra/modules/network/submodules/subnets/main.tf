module "subnets_module" {
	source = "terraform-google-modules/network/google//modules/subnets"

	project_id   = var.project_id
	network_name = var.vpc_name

	subnets = [
		{
			subnet_name           = var.subnet_name
			subnet_ip             = var.subnet_cidr
			subnet_region         = var.region
			subnet_private_access = var.subnet_type == "private" && var.enable_private_googleapis ? "true" : "false"
			description           = var.subnet_type == "public" ? "Public subnet for internet reachable instances" : "Private subnet for internal workloads"
		}
	]
}
