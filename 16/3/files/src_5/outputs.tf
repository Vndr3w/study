output "all_vms_list" {
  description = "Список всех созданных ВМ (web, db, storage) в виде словарей"
  value = concat(
    [for vm in yandex_compute_instance.web_count : {
      name = vm.name
      id   = vm.id
      fqdn = vm.fqdn
    }],

    [for name, vm in yandex_compute_instance.db_for_each : {
      name = name
      id   = vm.id
      fqdn = vm.fqdn
    }],

    [{
      name = yandex_compute_instance.storage.name
      id   = yandex_compute_instance.storage.id
      fqdn = yandex_compute_instance.storage.fqdn
    }]
  )
}