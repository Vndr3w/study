output "marketing_vm_fqdn" {
  value = module.vm["marketing"].fqdn
}

output "analytics_vm_fqdn" {
  value = module.vm["analytics"].fqdn
}