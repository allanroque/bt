output "web_public_ips" {
  description = "IPs públicos dos web servers"
  value       = aws_instance.web[*].public_ip
}

output "web_private_ips" {
  description = "IPs privados dos web servers"
  value       = aws_instance.web[*].private_ip
}

output "web_instance_ids" {
  description = "IDs das instâncias (usado para snapshots no descomissionamento)"
  value       = aws_instance.web[*].id
}

output "vpc_id" {
  value = aws_vpc.demo.id
}

output "app_urls" {
  description = "URLs da aplicação para validação na demo"
  value       = [for ip in aws_instance.web[*].public_ip : "http://${ip}"]
}
