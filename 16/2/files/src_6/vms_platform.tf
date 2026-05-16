variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

# Ресурсы для виртуальных машин web и db

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
    web = {
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
    db = {
      cores         = 2
      memory        = 4
      core_fraction = 20
      hdd_size      = 5
      hdd_type      = "network-hdd"
      platform_id   = "standard-v2"
      preemptible   = true
      nat           = false
      zone          = "ru-central1-b"
      cidr          = ["10.0.2.0/24"]
    }
  }
}

/* Не стал хардкодить ssh, а по другому не получается, вынес в locals.tf
variable "metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
    ssh-keys           = "ssh..."
  }
}
*/