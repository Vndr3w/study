locals {
  ssh_public_key  = sensitive(file("~/.ssh/ssh-key-1776007530027.pub"))
  common_metadata = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:${local.ssh_public_key}"
  }
}