variable "subnet_ids" {
  type        = list(any)
  description = "List of lambda VPC subnet ids"
}

variable "account_id" {
  type        = string
  description = "Current account ID"
}

variable "vpc_id" {
  type        = string
  description = "Main vpc ID"
}

variable "api_gw_execution_arn" {
  description = "API Gateway's execution ARN"
  type        = string
}