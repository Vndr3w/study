resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "a-zone-${ var.vpc_name }"
  zone           = var.vms_resources["web"].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vms_resources["web"].cidr
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "b-zone-${ var.vpc_name }"
  zone           = var.vms_resources["db"].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vms_resources["db"].cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.yandex_compute_image
}

resource "yandex_compute_instance" "vm_web" {
  name        = local.vm_web_name
  platform_id = var.vms_resources["web"].platform_id
  zone        = var.vms_resources["web"].zone
  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["web"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = var.vms_resources["web"].nat
  }

  metadata = local.common_metadata
}

resource "yandex_compute_instance" "vm_db" {
  name        = local.vm_db_name
  platform_id = var.vms_resources["db"].platform_id
  zone        = var.vms_resources["db"].zone
  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["db"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = var.vms_resources["db"].nat
  }

  metadata = local.common_metadata
}