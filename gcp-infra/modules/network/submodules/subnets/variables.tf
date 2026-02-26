variable "project_id" {
	type = string
}

variable "region" {
	type = string
}

variable "vpc_name" {
	type = string
}

variable "public_subnet_name" {
	type = string
}

variable "private_subnet_name" {
	type = string
}

variable "public_subnet_cidr" {
	type = string
}

variable "private_subnet_cidr" {
	type = string
}

variable "enable_private_googleapis" {
	type = bool
}
