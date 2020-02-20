output "url" {
  value       = module.alb-stack.elb_dns_name
  description = "The domain name of the load balancer"
}