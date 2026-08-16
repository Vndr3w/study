output "web_count_info" {
  value = {
    for idx, vm in yandex_compute_instance.web_count :
    vm.name => {
      external_ip = vm.network_interface[0].nat_ip_address
      fqdn        = vm.fqdn
    }
  }
}

output "db_for_each_info" {
  value = {
    for name, vm in yandex_compute_instance.db_for_each :
    name => {
      external_ip = vm.network_interface[0].nat_ip_address
      fqdn        = vm.fqdn
    }
  }
}

output "storage_info" {
  value = {
    instance_name = yandex_compute_instance.storage.name
    external_ip   = yandex_compute_instance.storage.network_interface[0].nat_ip_address
    fqdn          = yandex_compute_instance.storage.fqdn
    attached_disks = yandex_compute_disk.data_disk[*].name
  }
}