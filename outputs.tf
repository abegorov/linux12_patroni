output "private_ips" {
  description = "Private IPs of the instances."
  value = {
    for h in concat(
      yandex_compute_instance.backend
    ) : h.hostname => h.network_interface.0.ip_address
  }
}
output "public_ips" {
  description = "Public IPs of the instances."
  value = {
    for h in concat(
      yandex_compute_instance.backend
    ) : h.hostname => h.network_interface.0.nat_ip_address
  }
}
output "load_balancer" {
  description = "Public IP of the load balancer listeners."
  value = {
    for l in yandex_lb_network_load_balancer.backend.listener:
      l.name => one(l.external_address_spec).address
  }
}
