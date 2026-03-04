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

variable "subnet_type" {
	description = "Subnet role in this VPC: public or private."
	type        = string
}

variable "subnet_name" {
	description = "Subnet name in this VPC."
	type        = string
}

variable "subnet_cidr" {
	description = "Subnet CIDR block in this VPC."
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

variable "peer_cidrs" {
	description = "Other peered VPC CIDRs allowed for east-west traffic."
	type        = list(string)
	default     = []
}

variable "enable_private_googleapis" {
	description = "Enable Private Google Access for private subnet."
	type        = bool
}
