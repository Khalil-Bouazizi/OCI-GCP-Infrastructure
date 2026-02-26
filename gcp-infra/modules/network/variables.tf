variable "project_id" {
	description = "Project ID where network resources are created."
	type        = string
}

variable "region" {
	description = "Region for network resources."
	type        = string
}

variable "vpc_name" {
	description = "VPC network name."
	type        = string
}

variable "cidr_block" {
	description = "VPC CIDR block for private internal ingress firewall rule."
	type        = string
}

variable "public_subnet_name" {
	description = "Public subnet name."
	type        = string
}

variable "private_subnet_name" {
	description = "Private subnet name."
	type        = string
}

variable "public_subnet_cidr" {
	description = "Public subnet CIDR block."
	type        = string
}

variable "private_subnet_cidr" {
	description = "Private subnet CIDR block."
	type        = string
}

variable "public_ingress_cidrs" {
	description = "Allowed source CIDRs for public ingress rule."
	type        = list(string)
}

variable "public_ingress_tcp_ports" {
	description = "Allowed inbound TCP ports on public instances."
	type        = list(number)
}

variable "enable_private_googleapis" {
	description = "Enable Private Google Access for private subnet."
	type        = bool
}

variable "service_gateway_cidr" {
	description = "Google APIs restricted VIP route CIDR for private instances."
	type        = string
}
