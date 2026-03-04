organization_id = "********"

create_folder = false
folder_name   = "infra-shared"
folder_id     = null

create_project   = true
project_id       = "infra-oci-gcp-demo-001"
project_name     = "infra-oci-gcp-demo"
billing_account  = "000000-000000-000000"

region = "europe-west1"
zone   = "europe-west1-b"

enable_apis = [
	"compute.googleapis.com",
	"storage.googleapis.com"
]

create_state_bucket   = true
state_bucket_name     = "infra-oci-gcp-demo-001-tfstate"
state_bucket_location = "EU"
state_bucket_prefix   = "gcp-infra/state"

network_supernet_cidr = "10.0.0.0/8"
vpc_newbits           = 8
subnet_newbits        = 8
public_subnet_netnum  = 1
private_subnet_netnum = 2

vpcs = {
	hub = {
		subnet_type               = "public"
		cidr_block                = "10.0.0.0/24"
		subnet_name               = "hub-subnet"
		subnet_cidr               = "10.0.0.0/24"
		public_ingress_cidrs      = ["0.0.0.0/0"] # you could restrict this to known IPs or ranges for better security
		public_ingress_tcp_ports  = [22]
		enable_private_googleapis = false
	}

	spoke-a = {
		subnet_type               = "private"
		cidr_block                = "10.0.1.0/24"
		subnet_name               = "spoke-a-subnet"
		subnet_cidr               = "10.0.1.0/24"
		public_ingress_cidrs      = []
		public_ingress_tcp_ports  = []
		enable_private_googleapis = true
	}
}

instances = {
	vm-hub = {
		vpc_key          = "hub"
		subnet_type      = "public"
		machine_type     = "e2-micro"
		image            = "debian-cloud/debian-12"
		assign_public_ip = true
		network_tags     = ["public", "hub"]
		ssh_username        = "replace_user"
		ssh_public_key_path = "~/.ssh/id_rsa.pub"
	}
}
