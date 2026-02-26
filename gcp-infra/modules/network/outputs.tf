output "vpc_self_link" {
	value = module.vpc.vpc_self_link
}

output "public_subnet_self_link" {
	value = module.subnets.public_subnet_self_link
}

output "private_subnet_self_link" {
	value = module.subnets.private_subnet_self_link
}
