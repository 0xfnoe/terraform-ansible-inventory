variable "ssh_key_path" {}
variable "ssh_key_name" {}
variable "server_count" {}
variable "server_image" {}
variable "server_name_prefix" {}
variable "server_type" {}

# HCLOUD_TOKEN environment variable must be set
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.21.0"
    }
  }
}

locals {
  ds_count = length(data.hcloud_datacenters.all.names)
}

data "hcloud_datacenters" "all" {} 

resource "hcloud_ssh_key" "new" {
  name = var.ssh_key_name
  public_key = file("${var.ssh_key_path}")
}

resource "hcloud_server" "masters" {
  count = var.server_count
  image = var.server_image
  name = format("${var.server_name_prefix}-%02s", count.index + 1)
  server_type = var.server_type
  datacenter = data.hcloud_datacenters.all.names[count.index%local.ds_count]
  ssh_keys = [hcloud_ssh_key.new.name]
}

# this is an ansible inventory
output "ansible_inventory" {
  value = {
    myhosts = [
      for ip in hcloud_server.masters.*.ipv4_address :
      ip if length(ip) > 0
    ]
  }
}
