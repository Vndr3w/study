locals {
  vms = {
    marketing = {
      name        = "marketing-vm"
      project     = "marketing"
    }
    analytics = {
      name        = "analytics-vm"
      project     = "analytics"
    }
  }
}

locals {
  ssh_public_key = sensitive(file(var.public_key))
}

locals {
  service_account_key_path = pathexpand(var.service_account_key_file)
}