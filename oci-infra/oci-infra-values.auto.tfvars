# terraform.tfvars - replace the values with your own configuration

tenancy_ocid = "ocid1.tenancy.oc1.." # replace with your tenancy OCID
region       = "eu-paris-1" # replace with your OCI region

compartment_name          = "oci-infra"
compartment_enable_delete = true

network_supernet_cidr = "10.0.0.0/8"
vcn_newbits           = 8
subnet_newbits        = 8

vcns = {
  dmz = {  # dmz is the key of map
    role      = "dmz"
    vcn_index = 10
  }

  spoke-a = {
    role      = "spoke"
    vcn_index = 20
  }
}

subnets = {
  dmz-management = {
    vcn_key                  = "dmz"
    subnet_netnum            = 0
    ingress_cidrs            = ["0.0.0.0/0"]
    ingress_tcp_ports        = [22]
    assign_public_ip_on_vnic = true
    internet_access          = true
  }

  spoke-a-workload = {
    vcn_key                  = "spoke-a"
    subnet_netnum            = 1
    ingress_cidrs            = ["10.10.0.0/16"]
    ingress_tcp_ports        = [22]
    assign_public_ip_on_vnic = false
    internet_access          = true
  }
}

instances = {
  bastion-host = {
    subnet_key          = "dmz-management"
    availability_domain = null
    fault_domain        = null
    image_ocid          = "ocid1.image.oc1..replace_me"
    ssh_public_key_path = "***/id_rsa.pub"
    shape               = "VM.Standard.E2.1.Micro"
    assign_public_ip    = true
  }

  spoke-a-instance = {
    subnet_key          = "spoke-a-workload"
    availability_domain = null
    fault_domain        = null
    image_ocid          = "ocid1.image.oc1..replace_me"
    ssh_public_key_path = "***/id_rsa.pub"
    shape               = "VM.Standard.E2.1.Micro"
    assign_public_ip    = false
  }
}

create_state_bucket  = true
state_bucket_name    = "oci-infra-tfstate"
state_bucket_prefix  = "oci-infra/state"
