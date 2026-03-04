resource "google_project_service" "required" {
	for_each = toset(var.enable_apis)

	project            = var.project_id
	service            = each.value
	disable_on_destroy = false

	depends_on = [
		google_project.project
	]
}
