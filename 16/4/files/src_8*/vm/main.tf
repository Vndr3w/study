# Получаем данные о сети из state-файла модуля vpc
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

locals {
  ssh_public_key = sensitive(file(var.public_key))

  vms = {
    marketing = {
      name    = "marketing-vm"
      project = "marketing"
      zone    = "ru-central1-a"
    }
    analytics = {
      name    = "analytics-vm"
      project = "analytics"
      zone    = "ru-central1-b"
    }
  }
}

module "vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  for_each = local.vms

  network_id     = data.terraform_remote_state.vpc.outputs.network_id
  subnet_zones   = [each.value.zone]
  subnet_ids     = [data.terraform_remote_state.vpc.outputs.subnet_ids[each.value.zone]]
  instance_name  = each.value.name
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = false
  labels = {
    project = each.value.project
  }
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yml", { ssh_public_key = local.ssh_public_key })
    serial-port-enable = 1
  }
}