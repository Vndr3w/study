variable "env_name" {
  description = "Название окружения (используется в именах ресурсов)"
  type        = string
}

variable "subnets" {
  description = "Список подсетей для создания: зона и CIDR"
  type = list(object({
    zone = string
    cidr = string
  }))
}