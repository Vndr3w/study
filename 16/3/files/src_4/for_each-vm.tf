resource "yandex_compute_instance" "db_for_each" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name        = each.value.vm_name
  platform_id = var.vms_resources["vms"].platform_id
  zone        = var.vms_resources["vms"].zone

  resources {
    cores         = each.value.cpu
    memory        = each.value.ram
    core_fraction = var.vms_resources["vms"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
      type     = var.vms_resources["vms"].hdd_type
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
}