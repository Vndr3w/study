locals {
  vm_external_ips = [
    for vm in yandex_compute_instance.vm :
    vm.network_interface[0].nat_ip_address
  ]
}

resource "local_file" "ansible_hosts" {
  filename = "${path.module}/hosts.ini"

  content = <<EOT
[web]
%{ for idx, ip in local.vm_external_ips ~}
vm${idx} ansible_host=${ip} ansible_user=ubuntu
%{ endfor ~}
EOT
}