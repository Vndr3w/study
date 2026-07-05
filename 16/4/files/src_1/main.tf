#создаем облачную сеть
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

#создаем подсеть
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

module "vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  for_each = local.vms

  # env_name      = ""
  network_id    = yandex_vpc_network.develop.id
  subnet_zones  = [each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"]
  subnet_ids    = [each.key == "marketing" ? yandex_vpc_subnet.develop_a.id : yandex_vpc_subnet.develop_b.id]
  instance_name = each.value.name
  instance_count = 1
  image_family  = "ubuntu-2004-lts"
  public_ip     = true
  labels = {
    project = each.value.project
  }
  metadata = {
    user-data = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}

#Пример передачи cloud-config в ВМ для демонстрации №3

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_public_key = local.ssh_public_key
  }
}

