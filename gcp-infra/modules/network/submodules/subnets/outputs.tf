output "vpc_self_link" {
	value = format("projects/%s/global/networks/%s", var.project_id, var.vpc_name)
}

output "public_subnet_self_link" {
	value = format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.public_subnet_name)
}

output "private_subnet_self_link" {
	value = format("projects/%s/regions/%s/subnetworks/%s", var.project_id, var.region, var.private_subnet_name)
}

output "subnets" {
	value = module.subnets_module.subnets
}
