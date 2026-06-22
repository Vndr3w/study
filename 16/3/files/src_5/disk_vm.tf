resource "yandex_compute_disk" "data_disk" {
  count = 3

  name = "disk-${count.index + 1}"
  type = var.vms_resources["vms"].hdd_type
  zone = var.default_zone
  size = 1
}

resource "yandex_compute_instance" "storage" {
  name = "storage"

  platform_id = var.vms_resources["vms"].platform_id
  zone        = var.default_zone

  resources {
    cores         = var.vms_resources["vms"].cores
    memory        = var.vms_resources["vms"].memory
    core_fraction = var.vms_resources["vms"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vms_resources["vms"].hdd_size
      type     = var.vms_resources["vms"].hdd_type
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.data_disk[*].id
    content {
      disk_id     = secondary_disk.value
    }
  }

  scheduling_policy {
    preemptible = var.vms_resources["vms"].preemptible
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = var.vms_resources["vms"].nat
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = local.common_metadata

  depends_on = [yandex_compute_disk.data_disk]
}