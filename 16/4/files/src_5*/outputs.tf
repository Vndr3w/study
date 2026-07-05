output "vm_fqdns" {
  description = "FQDN всех созданных ВМ"
  value = {
    for name, vm in module.vm : name => vm.fqdn
  }
}

output "mysql_cluster_id" {
  value = module.mysql_cluster.cluster_id
}

output "mysql_master_fqdn" {
  value = module.mysql_cluster.cluster_fqdn
}

output "mysql_database_name" {
  value = module.mysql_db_user.database_name
}