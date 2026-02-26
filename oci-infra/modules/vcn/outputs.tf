output "vcn_id" {
  value = oci_core_vcn.oci_global_vcn_details.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.oci_internet_gateway_details.id
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.oci_nat_gateway_details.id
}
