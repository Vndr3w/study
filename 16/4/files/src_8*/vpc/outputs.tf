output "network_id" {
  value = yandex_vpc_network.network.id
}

output "subnet_ids" {
  value = {
    for zone, subnet in yandex_vpc_subnet.subnet : zone => subnet.id
  }
}