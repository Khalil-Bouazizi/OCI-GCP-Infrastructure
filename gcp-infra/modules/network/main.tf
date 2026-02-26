module "vpc" {
	source = "./submodules/vpc"

	project_id   = var.project_id
 	vpc_name     = var.vpc_name
}

module "subnets" {
	source = "./submodules/subnets"

	project_id                = var.project_id
	region                    = var.region
	vpc_name                  = var.vpc_name
	public_subnet_name        = var.public_subnet_name
	private_subnet_name       = var.private_subnet_name
	public_subnet_cidr        = var.public_subnet_cidr
	private_subnet_cidr       = var.private_subnet_cidr
	enable_private_googleapis = var.enable_private_googleapis

	depends_on = [
		module.vpc
	]
}

module "routes" {
	source = "./submodules/routes"

	project_id                = var.project_id
	vpc_name                  = var.vpc_name
	service_gateway_cidr      = var.service_gateway_cidr
	enable_private_googleapis = var.enable_private_googleapis

	depends_on = [
		module.subnets
	]
}

module "firewall_rules" {
	source = "./submodules/firewall-rules"

	project_id               = var.project_id
	vpc_name                 = var.vpc_name
	cidr_block               = var.cidr_block
	public_ingress_cidrs     = var.public_ingress_cidrs
	public_ingress_tcp_ports = var.public_ingress_tcp_ports

	depends_on = [
		module.subnets
	]
}
