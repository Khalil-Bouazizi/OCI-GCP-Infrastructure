resource "google_compute_firewall" "private_internal" {
	for_each = local.vpcs_resolved

	name        = "${each.key}-private-internal"
	description = "Allow internal east-west tcp and icmp between peered VPCs"
	project     = var.project_id
	network     = each.key

	direction     = "INGRESS"
	source_ranges = distinct(concat([each.value.cidr_block], [for peer_name, peer in local.vpcs_resolved : peer.cidr_block if peer_name != each.key]))
	target_tags   = ["private"]

	allow {
		protocol = "tcp"
	}

	allow {
		protocol = "icmp"
	}

	depends_on = [
		module.subnets
	]
}

resource "google_compute_firewall" "public_ssh" {
	for_each = {
		for name, vpc in local.vpcs_resolved :
		name => vpc
		if vpc.subnet_type == "public" && contains(vpc.public_ingress_tcp_ports, 22)
	}

	name        = "${each.key}-public-ingress-ssh"
	description = "Allow SSH to public-tagged instances"
	project     = var.project_id
	network     = each.key

	direction     = "INGRESS"
	source_ranges = each.value.public_ingress_cidrs
	target_tags   = ["public"]

	allow {
		protocol = "tcp"
		ports    = ["22"]
	}

	depends_on = [
		module.subnets
	]
}