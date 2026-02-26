# like a recipe or template you can use multiple times.
# You write the VCN code once in main.tf, then reuse it by calling it with different values

resource "oci_core_vcn" "oci_global_vcn_details" {
  compartment_id = var.compartment_id
  cidr_block     = var.cidr_block
  display_name   = var.vcn_name
  dns_label      = var.dns_label

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_internet_gateway" "oci_internet_gateway_details" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-igw"
  enabled        = true

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_nat_gateway" "oci_nat_gateway_details" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-nat"

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oci_internet_gateway_details.id
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oci_nat_gateway_details.id
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-public-sl"

  dynamic "ingress_security_rules" {
    for_each = {
      for item in flatten([
        for cidr in var.public_ingress_cidrs : [
          for port in var.public_ingress_tcp_ports : {
            cidr = cidr
            port = port
          }
        ]
      ]) : "${item.cidr}-${item.port}" => item
    }
    content {
      protocol = "6"
      source   = ingress_security_rules.value.cidr

      tcp_options {
        min = ingress_security_rules.value.port
        max = ingress_security_rules.value.port
      }
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.oci_global_vcn_details.id
  display_name   = "${var.vcn_name}-private-sl"

  ingress_security_rules {
    source   = var.cidr_block
    protocol = "all"
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.oci_global_vcn_details.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "${var.vcn_name}-public-subnet"
  dns_label                  = var.public_subnet_dns_label
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.oci_global_vcn_details.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.vcn_name}-private-subnet"
  dns_label                  = var.private_subnet_dns_label
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
