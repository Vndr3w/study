# Модуль VPC для зоны ru-central1-a
module "vpc_a" {
  source   = "./vpc"
  env_name = "develop"
  zone     = "ru-central1-a"
  cidr     = "10.0.1.0/24"
}

# Модуль VPC для зоны ru-central1-b
module "vpc_b" {
  source   = "./vpc"
  env_name = "develop"
  zone     = "ru-central1-b"
  cidr     = "10.0.2.0/24"
}

# Сопоставление зон с модулями VPC
locals {
  vpc_by_zone = {
    "ru-central1-a" = module.vpc_a
    "ru-central1-b" = module.vpc_b
  }
}

# Модуль виртуальных машин
module "vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  for_each = local.vms

  network_id    = local.vpc_by_zone[each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"].network_id
  subnet_zones  = [each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"]
  subnet_ids    = [local.vpc_by_zone[each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"].subnet_id]
  instance_name = each.value.name
  instance_count = 1
  image_family  = "ubuntu-2004-lts"
  public_ip     = true
  labels = {
    project = each.value.project
  }
  metadata = {
    user-data = templatefile("./cloud-init.yml", { ssh_public_key = local.ssh_public_key })
    serial-port-enable = 1
  }
}