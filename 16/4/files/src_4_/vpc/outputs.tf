output "network_id" {
  description = "ID созданной сети VPC"
  value       = yandex_vpc_network.this.id
}

output "subnet_ids" {
  description = "Сопоставление зоны -> ID подсети"
  value = {
    for zone, subnet in yandex_vpc_subnet.this : zone => subnet.id
  }
}

output "subnet_cidrs" {
  description = "Сопоставление зоны -> CIDR подсети"
  value = {
    for zone, subnet in yandex_vpc_subnet.this : zone => subnet.v4_cidr_blocks[0]
  }
}