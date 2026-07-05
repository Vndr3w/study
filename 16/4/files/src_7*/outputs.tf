output "vm_fqdns" {
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

output "s3_bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "read_example" {
  value = nonsensitive(data.vault_kv_secret_v2.example.data)
}

output "read_test_key" {
  value = nonsensitive(data.vault_kv_secret_v2.example.data["test"])
}