output "cluster_id" {
  value = yandex_mdb_mysql_cluster.cluster.id
}

output "cluster_fqdn" {
  value = yandex_mdb_mysql_cluster.cluster.host[0].fqdn
}