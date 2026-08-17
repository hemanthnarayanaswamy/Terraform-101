output "instance_names" {
  value = [for vm in google_compute_instance.vms : vm.name]
}

output "external_ips" {
  value = [for vm in google_compute_instance.vms : vm.network_interface[0].access_config[0].nat_ip]
}
