locals {
  vm_web_name     = "${ var.project }-${ var.env }-${ var.platform }-web"
  vm_db_name      = "${ var.project }-${ var.env }-${ var.platform }-db"
  common_metadata = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}