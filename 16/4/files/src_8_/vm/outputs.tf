output "vm_fqdns" {
  value = {
    for name, vm in module.vm : name => vm.fqdn
  }
}