variable "compartment_id" {
  description = "Compartment OCID where VCN resources are created."
  type        = string
}

variable "vcn_name" {
  description = "VCN name prefix."
  type        = string
}

variable "cidr_block" {
  description = "VCN CIDR block."
  type        = string
}

variable "dns_label" {
  description = "DNS label for VCN."
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet."
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet."
  type        = string
}

variable "public_subnet_dns_label" {
  description = "DNS label for public subnet."
  type        = string
}

variable "private_subnet_dns_label" {
  description = "DNS label for private subnet."
  type        = string
}

variable "public_ingress_cidrs" {
  description = "Allowed CIDRs for inbound access to public subnet security list."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "public_ingress_tcp_ports" {
  description = "Allowed inbound TCP ports from public_ingress_cidrs on public subnet security list."
  type        = list(number)
  default     = [22]
}

variable "freeform_tags" {
  description = "Freeform tags for VCN resources."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for VCN resources."
  type        = map(string)
  default     = {}
}
