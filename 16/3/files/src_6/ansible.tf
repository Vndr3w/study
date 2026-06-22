locals {
  webservers = [
    for vm in yandex_compute_instance.web_count : {
      name        = vm.name
      external_ip = vm.network_interface[0].nat_ip_address != "" ? vm.network_interface[0].nat_ip_address : ""
      internal_ip = vm.network_interface[0].ip_address
      fqdn        = vm.fqdn
    }
  ]

  databases = [
    for name, vm in yandex_compute_instance.db_for_each : {
      name        = name
      external_ip = vm.network_interface[0].nat_ip_address != "" ? vm.network_interface[0].nat_ip_address : ""
      internal_ip = vm.network_interface[0].ip_address
      fqdn        = vm.fqdn
    }
  ]

  storage = [
    {
      name        = yandex_compute_instance.storage.name
      external_ip = yandex_compute_instance.storage.network_interface[0].nat_ip_address != "" ? yandex_compute_instance.storage.network_interface[0].nat_ip_address : ""
      internal_ip = yandex_compute_instance.storage.network_interface[0].ip_address
      fqdn        = yandex_compute_instance.storage.fqdn
    }
  ]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.webservers
    databases  = local.databases
    storage    = local.storage
  })
  filename = "${path.module}/inventory.ini"
}

resource "null_resource" "ansible_provision" {
  triggers = {
    inventory_hash = sha1(file("${path.module}/inventory.ini"))
    playbook_hash  = sha1(file("${path.module}/playbook.yml"))
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/inventory.ini ${path.module}/playbook.yml || true"
  }

  depends_on = [local_file.ansible_inventory]
}