 # get availability domains from OCI 

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
} 

# You can access: data.oci_identity_availability_domains.ads.availability_domains[0].name
