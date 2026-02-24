output "vcn_id" {
  value = oci_core_vcn.this.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.this.id
}
