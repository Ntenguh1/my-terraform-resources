output "alb_dns" {
  description = "DNS name of my ALB"
  value       = aws_lb.terraformALB.dns_name
}