# Imprime direccion publica del servidor
output "dns_publica_server1" {
  description = "DNS publica del servidor 1"
  value       = "http://${aws_instance.server_1.public_dns}:8080"
}

output "dns_publica_server2" {
  description = "DNS publica del servidor 2"
  value       = "http://${aws_instance.server_2.public_dns}:8080"
}

output "dns_loadbalancer" {
  description = "DNS publica del loadbalacner"
  value       = "http://${aws_lb.albfeog.dns_name}"
}
