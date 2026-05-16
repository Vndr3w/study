###cloud vars

variable "cloud_id" {
  type        = string
  default     = "b1g4hsvetd251u6o7208"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gmq7jclnbgs94c9kq1"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

### pc vars

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vpc_family_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "vpc_name_vm" {
  type        = string
  default     = "netology-develop-platform-web"
}
variable "vpc_platform_id" {
  type        = string
  default     = "standard-v2"
}

variable "vpc_cores" {
  type        = number
  default     = 2
}

variable "vpc_memory" {
  type        = number
  default     = 1
}

variable "vpc_core_fraction" {
  type        = number
  default     = 5
}

variable "vpc_preemptible" {
  type        = bool
  default     = true
}

variable "vpc_nat" {
  type        = bool
  default     = true
}

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1y..."
  description = "ssh-keygen -t ed25519"
}