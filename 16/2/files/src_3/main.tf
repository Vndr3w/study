resource "yandex_vpc_network" "develop" {
  name = "vm_web_${ var.vm_web_net }"
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "vm_web_${ var.vm_web_net }"
  zone           = var.default_zone_web
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_a
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "vm_db_${ var.vm_web_net }"
  zone           = var.default_zone_db
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_b
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family_image
}

resource "yandex_compute_instance" "vm_web" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  zone        = var.vm_web_zone
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}

resource "yandex_compute_instance" "vm_db" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_zone
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = var.vm_db_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}