module "vpc" {
  source   = "./vpc"
  env_name = var.env_name
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" }
  ]
}

module "vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  for_each = local.vms

  network_id     = module.vpc.network_id
  subnet_zones   = [each.value.zone]
  subnet_ids     = [module.vpc.subnet_ids[each.value.zone]]
  instance_name  = each.value.name
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = false
  labels = {
    project = each.value.project
  }
  metadata = {
    user-data = templatefile("./cloud-init.yml", { ssh_public_key = local.ssh_public_key })
    serial-port-enable = 1
  }
}

module "mysql_cluster" {
  source = "./mysql-cluster"

  cluster_name      = var.mysql_cluster_name
  network_id        = module.vpc.network_id
  subnet_ids        = local.mysql_subnet_ids
  high_availability = var.mysql_ha
  environment       = var.mysql_environment
}

module "mysql_db_user" {
  source = "./mysql-db-user"

  cluster_id     = module.mysql_cluster.cluster_id
  database_name  = var.mysql_db_name
  user_name      = var.mysql_user_name
  user_password  = var.mysql_user_password

  depends_on = [module.mysql_cluster]
}

resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

module "s3_bucket" {
  source = "git::https://github.com/terraform-yc-modules/terraform-yc-s3.git?ref=master"

  bucket_name = "my-bucket-${random_string.bucket_suffix.result}"
  versioning = {
    enabled = true
  }
  max_size = 1073741824
}