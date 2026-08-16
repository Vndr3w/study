locals {
  ssh_public_key            = sensitive(file(var.public_key))
  service_account_key_path  = pathexpand(var.service_account_key_file)
  mysql_subnet_ids = [
    module.vpc.subnet_ids["ru-central1-a"],
    module.vpc.subnet_ids["ru-central1-b"]
  ]

  vms = {
    marketing = {
      name    = "marketing-vm"
      project = "marketing"
      zone    = "ru-central1-a"
    }
    analytics = {
      name    = "analytics-vm"
      project = "analytics"
      zone    = "ru-central1-b"
    }
  }
}