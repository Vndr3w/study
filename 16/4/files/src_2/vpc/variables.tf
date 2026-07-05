variable "env_name" {
  description = "Environment name (used for resource naming)"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
}

variable "cidr" {
  description = "IPv4 CIDR block for the subnet"
  type        = string
}