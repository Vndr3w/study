resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vms_resources["vms"].cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.yandex_compute_image
}