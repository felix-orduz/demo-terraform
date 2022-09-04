output "Servers_Creados" {
  description = "Servidores Creados"
  value       = { for server in aws_instance.servers : "${server.arn}" => "http://${server.public_dns}:8080" }
}

output "loadbalancer" {
  description = "DNS publica del loadbalancer"
  value       = "http://${aws_lb.alb.dns_name}"
}
