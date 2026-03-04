variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_type" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_ingress_cidrs" {
  type = list(string)
}

variable "public_ingress_tcp_ports" {
  type = list(number)
}

variable "peer_cidrs" {
  type    = list(string)
  default = []
}
