output "alb_dns" {
  description = "DNS name of my ALB"
  value       = aws_lb.terraformALB.dns_name
}

output "tg_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.terraformTG.arn
}