resource "yandex_mdb_mysql_cluster" "cluster" {
  name               = var.cluster_name
  environment        = var.environment
  network_id         = var.network_id
  version            = var.mysql_version

  resources {
    resource_preset_id = var.resources.resource_preset_id
    disk_size          = var.resources.disk_size
    disk_type_id       = var.resources.disk_type_id
  }

  dynamic "host" {
    for_each = var.high_availability ? [0, 1] : [0]
    content {
      zone      = element(["ru-central1-a", "ru-central1-b"], host.value)
      subnet_id = element(var.subnet_ids, host.value)
      assign_public_ip = false
    }
  }

  mysql_config = {
    sql_mode = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks = true
  }
}