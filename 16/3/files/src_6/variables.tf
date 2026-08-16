variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
    platform_id   = string
    preemptible   = bool
    nat           = bool
    zone          = string
    cidr          = list(string)
  }))
  default = {
    vms = {
      cores         = 2
      memory        = 1
      core_fraction = 5
      hdd_size      = 5
      hdd_type      = "network-hdd"
      platform_id   = "standard-v2"
      preemptible   = true
      nat           = false
      zone          = "ru-central1-a"
      cidr          = ["10.0.1.0/24"]
    }
  }  
}

variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
  default = [
    { vm_name = "main", cpu = 2, ram = 2, disk_volume = 5 },
    { vm_name = "replica", cpu = 2, ram = 2, disk_volume = 5 }
  ]
}

variable "yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}