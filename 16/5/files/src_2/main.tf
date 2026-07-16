module "vpc" {
  source   = "./vpc"
  env_name = "develop"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" }
  ]
}

module "vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  for_each = local.vms

  network_id    = module.vpc.network_id
  subnet_zones  = [each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"]
  subnet_ids    = [module.vpc.subnet_ids[each.key == "marketing" ? "ru-central1-a" : "ru-central1-b"]]
  instance_name = each.value.name
  instance_count = 1
  image_family  = "ubuntu-2004-lts"
  public_ip     = false
  labels = {
    project = each.value.project
  }
  metadata = {
    user-data = templatefile("./cloud-init.yml", { ssh_public_key = local.ssh_public_key })
    serial-port-enable = 1
  }
}