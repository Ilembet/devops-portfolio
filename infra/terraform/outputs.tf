output "vm_public_ips" {
  description = "Public IP of each VM, keyed by zone"
  value       = { for zone, vm in yandex_compute_instance.vm : zone => vm.network_interface[0].nat_ip_address }
}

output "ssh_commands" {
  description = "Ready-to-use SSH commands"
  value       = [for vm in yandex_compute_instance.vm : "ssh ubuntu@${vm.network_interface[0].nat_ip_address}"]
}

output "health_urls" {
  description = "notes-api health check on each VM"
  value       = [for vm in yandex_compute_instance.vm : "http://${vm.network_interface[0].nat_ip_address}:8000/health"]
}
