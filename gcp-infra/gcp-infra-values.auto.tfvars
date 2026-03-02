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
	vpc-a = {
		vpc_index                = 10
		public_ingress_cidrs     = ["0.0.0.0/0"]
		public_ingress_tcp_ports = [22, 80, 443] # open SSH, HTTP, and HTTPS to the world for this VPC
		enable_private_googleapis = true # enable Private Google Access on private subnet for this VPC
	}

	vpc-b = {
		vpc_index                = 20
		public_ingress_cidrs     = ["0.0.0.0/0"]
		public_ingress_tcp_ports = [22]
	}
}

instances = {
	gcp-instance-public-01 = {
		vpc_key          = "vpc-a"
		subnet_type      = "public"
		machine_type     = "e2-micro"
		image            = "debian-cloud/debian-12"
		assign_public_ip = true
		network_tags     = ["ssh", "web"]
		ssh_username        = "replace_user"
		ssh_public_key_path = "~/.ssh/id_rsa.pub"
	}

	gcp-instance-private-01 = {
		vpc_key          = "vpc-a"
		subnet_type      = "private"
		machine_type     = "e2-micro"
		image            = "debian-cloud/debian-12"
		assign_public_ip = false
		network_tags     = ["internal"]
		ssh_username        = "replace_user"
		ssh_public_key_path = "~/.ssh/id_rsa.pub"
	}
}
