variable "base_cidr_block" {
  description = "The base CIDR block for subnet calculations."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_configs" {
  description = "metadescription of the subnets that exists whithin the base vpc"
  type = list(object({
    subnet_bits       = number
    availability_zone = string
    name              = string
  }))
  default = [
    {
      subnet_bits       = 8
      availability_zone = "us-east-1a"
      name              = "priv-1"
    },
    {
      subnet_bits       = 8
      availability_zone = "us-east-1b"
      name              = "priv-2"
    }
  ]
}
