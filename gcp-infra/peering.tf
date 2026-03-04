resource "google_compute_network_peering" "hub_to_spoke" {
	name         = "${var.hub_vpc_key}-to-${var.spoke_vpc_key}"
	network      = format("projects/%s/global/networks/%s", var.project_id, var.hub_vpc_key)
	peer_network = format("projects/%s/global/networks/%s", var.project_id, var.spoke_vpc_key)

	import_custom_routes = true
	export_custom_routes = true

	depends_on = [
		module.vpc
	]
}

resource "google_compute_network_peering" "spoke_to_hub" {
	name         = "${var.spoke_vpc_key}-to-${var.hub_vpc_key}"
	network      = format("projects/%s/global/networks/%s", var.project_id, var.spoke_vpc_key)
	peer_network = format("projects/%s/global/networks/%s", var.project_id, var.hub_vpc_key)

	import_custom_routes = true
	export_custom_routes = true

	depends_on = [
		module.vpc
	]
}