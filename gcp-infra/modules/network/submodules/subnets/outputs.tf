output "vpc_self_link" {
	value = format("projects/%s/global/networks/%s", var.project_id, var.vpc_name)
}

output "public_subnet_self_link" {
	value = var.subnet_type == "public" ? format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnet_name) : null
}

output "private_subnet_self_link" {
	value = var.subnet_type == "private" ? format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.subnet_name) : null
}

output "subnets" {
	value = module.subnets_module.subnets
}
