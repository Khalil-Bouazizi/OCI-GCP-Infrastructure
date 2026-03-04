resource "google_folder" "folder" {
	count = var.create_folder ? 1 : 0

	display_name = var.folder_name
	parent       = "organizations/${var.organization_id}"
}

resource "google_project" "project" {
	count = var.create_project ? 1 : 0

	project_id      = var.project_id
	name            = var.project_name
	billing_account = var.billing_account
	folder_id       = var.create_folder ? google_folder.folder[0].name : var.folder_id
	org_id          = (!var.create_folder && var.folder_id == null) ? var.organization_id : null

	auto_create_network = false
}