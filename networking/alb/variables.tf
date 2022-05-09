variable "alb_name" {
  description = "Name of ALB"
  type        = string
}
variable "tg_name" {
  description = "Name of Target Group"
  type        = string
}
variable "alb_sg_name" {
  description = "Name of ALB Security Group"
  type = string
}