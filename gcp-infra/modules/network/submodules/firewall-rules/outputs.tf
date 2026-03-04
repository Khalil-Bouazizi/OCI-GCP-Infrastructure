output "firewall_rules" {
  value = {
    private_internal = google_compute_firewall.private_internal.name
    public_ssh       = try(google_compute_firewall.public_ssh[0].name, null)
  }
}
