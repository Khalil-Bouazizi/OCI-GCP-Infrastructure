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
	subnet_type               = var.subnet_type
	subnet_name               = var.subnet_name
	subnet_cidr               = var.subnet_cidr
	enable_private_googleapis = var.enable_private_googleapis

	depends_on = [
		module.vpc
	]
}

module "routes" {
	source = "./submodules/routes"

	project_id                = var.project_id
	vpc_name                  = var.vpc_name
	subnet_type               = var.subnet_type
	enable_private_googleapis = var.enable_private_googleapis

	depends_on = [
		module.subnets
	]
}

module "firewall_rules" {
	source = "./submodules/firewall-rules"

	project_id               = var.project_id
	vpc_name                 = var.vpc_name
	subnet_type              = var.subnet_type
	cidr_block               = var.cidr_block
	public_ingress_cidrs     = var.public_ingress_cidrs
	public_ingress_tcp_ports = var.public_ingress_tcp_ports
	peer_cidrs               = var.peer_cidrs

	depends_on = [
		module.subnets
	]
}
