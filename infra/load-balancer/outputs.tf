# File: infra/load-balancer/outputs.tf
output "aws_lb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}