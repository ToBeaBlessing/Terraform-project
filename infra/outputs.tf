output "dev_proj_1_vpc_id" {
  value = module.networking.dev_proj_1_vpc_id
}

# This will output the Load Balancer DNS name so you can access your app
output "alb_public_url" {
  description = "The public DNS name of the Application Load Balancer"
  value       = "http://${module.alb.aws_lb_dns_name}:5000"
}

# This outputs the RDS Endpoint (useful for connecting your app later)
output "rds_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = module.rds_db_instance.rds_endpoint
}

/*output "ec2_ssh_string" {
  value = module.ec2.ssh_connection_string_for_ec2
}

output "hosted_zone_id" {
  value = module.hosted_zone.hosted_zone_id
}*/