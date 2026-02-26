module "routes_module" {
	source = "terraform-google-modules/network/google//modules/routes"

	project_id   = var.project_id
	network_name = var.vpc_name
	routes = concat(
		[
			{
				name              = "${var.vpc_name}-public-default-route"
				description       = "Default internet route for public instances"
				destination_range = "0.0.0.0/0"
				tags              = ["public"]
				next_hop_internet = true
				priority          = 1000
			},
			{
				name              = "${var.vpc_name}-private-default-route"
				description       = "Default internet route for private instances"
				destination_range = "0.0.0.0/0"
				tags              = ["private"]
				next_hop_internet = true
				priority          = 1000
			}
		],
		var.enable_private_googleapis ? [
			{
				name              = "${var.vpc_name}-private-googleapis-route"
				description       = "Private Google APIs restricted VIP route"
				destination_range = var.service_gateway_cidr
				tags              = ["private"]
				next_hop_internet = true
				priority          = 900
			}
		] : []
	)
}
