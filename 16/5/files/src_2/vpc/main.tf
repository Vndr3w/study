resource "yandex_vpc_network" "this" {
  name = "${var.env_name}-network"
}

resource "yandex_vpc_subnet" "this" {
  for_each = { for idx, subnet in var.subnets : subnet.zone => subnet }
  name           = "${var.env_name}-subnet-${each.value.zone}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value.cidr]
}