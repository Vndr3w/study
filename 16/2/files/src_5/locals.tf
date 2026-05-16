locals {
  vm_web_name = "${ var.project }-${ var.env }-${ var.platform }-web"
  vm_db_name  = "${ var.project }-${ var.env }-${ var.platform }-db"
}