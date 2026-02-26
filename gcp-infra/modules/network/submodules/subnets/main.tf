module "subnets_module" {
	source = "terraform-google-modules/network/google//modules/subnets"

	project_id   = var.project_id
	network_name = var.vpc_name

	subnets = [
		{
			subnet_name           = var.public_subnet_name
			subnet_ip             = var.public_subnet_cidr
			subnet_region         = var.region
			subnet_private_access = "false"
			description           = "Public subnet for internet reachable instances"
		},
		{
			subnet_name           = var.private_subnet_name
			subnet_ip             = var.private_subnet_cidr
			subnet_region         = var.region
			subnet_private_access = var.enable_private_googleapis ? "true" : "false"
			description           = "Private subnet for internal workloads"
		}
	]
}
