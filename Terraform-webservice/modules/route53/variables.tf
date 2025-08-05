variable "zone_name" {
  description = "The Route53 hosted zone name (e.g. example.com.)"
  type        = string
}

variable "record_name" {
  description = "The DNS record name for Route53"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The zone ID of the ALB"
  type        = string
}

