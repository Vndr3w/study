packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

variable "YC_TOKEN" {
  type    = string
  default = "xxxx"
}

variable "YC_FOLDER_ID" {
  type    = string
  default = "xxxx"
}

variable "YC_SUBNET_ID" {
  type    = string
  default = "xxxx"
}

source "yandex" "debian-image" {
  token               = var.YC_TOKEN
  folder_id           = var.YC_FOLDER_ID
  zone                = "ru-central1-d"
  subnet_id           = var.YC_SUBNET_ID
  source_image_family = "debian-12"
  image_name          = "my-debian-with-docker-{{timestamp}}"
  image_family        = "my-custom-images"
  ssh_username        = "debian"
  use_ipv4_nat        = true
  disk_type           = "network-hdd"
}

build {
  sources = ["source.yandex.debian-image"]

  provisioner "shell" {
    inline = [
      # Обновление списка пакетов
      "sudo apt-get update",
      
      # Установка htop и tmux с автоматическим подтверждением
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y htop tmux",
      
      # Установка Docker (официальный скрипт)
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      
      # Добавление пользователя debian в группу docker, чтобы не использовать sudo
      "sudo usermod -aG docker debian",
      
      # Очистка
      "rm get-docker.sh",
      
      # Проверка установки
      "docker --version",
    ]
  }
}
