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