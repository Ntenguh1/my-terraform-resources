variable "cluster_name" {
    description = "Name of cluster"
    type = string
}
variable "template_instance_type" {
  description = "Instance type for launch template"
  type        = string
}
variable "key_pair" {
  description = "Key pair to be used for launch template"
  type        = string
}
variable "asg_desired" {
  description = "Desired number of instances in the ASG"
  type        = string
}
variable "asg_max" {
  description = "Maximum number of instances in the ASG"
  type        = string
}
variable "asg_min" {
  description = "Minimum number of instances in the ASG"
  type        = string
}
variable "custom_tags" {
  description = "Custom tags for instances in an ASG"
  type        = map(string)
  default     = {}
}
variable "enable_autoscaling_schedule" {
  description = "If set to true, enable auto scaling"
  type        = bool
}