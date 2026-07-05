variable "cluster_name" {
  type        = string
}

variable "network_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "high_availability" {
  type        = bool
  default     = false
}

variable "mysql_version" {
  type        = string
  default     = "8.0"
}

variable "environment" {
  type        = string
  default     = "PRESTABLE"
}

variable "resources" {
  type = object({
    resource_preset_id = string
    disk_size          = number
    disk_type_id       = string
  })
  default = {
    resource_preset_id = "s2.micro"   # 2 vCPU, 2 GB RAM
    disk_size          = 10           # 10 GB
    disk_type_id       = "network-ssd"
  }
}