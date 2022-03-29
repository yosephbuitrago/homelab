variable "mariadb" {
  default = {
    vm_name      = "mariadb"
    vm_template  = "ubuntu-2004-cloudinit-template"
    target_node  = "prox"
    cores        = "2"
    sockets      = "1"
    memory       = "2048"
    storage_type = "scsi"
    storage_id   = "QNAP"
    disk_size    = "10G"
    user         = "ubuntu"
    gt           = "10.0.0.1",
    cidr_prefix  = "24",
  }
}

variable "master_nodes" {
  default = {
    vm_name      = "master"
    vm_template  = "ubuntu-2004-cloudinit-template"
    target_node  = "prox"
    cores        = "2"
    sockets      = "1"
    memory       = "2048"
    storage_type = "scsi"
    storage_id   = "QNAP"
    disk_size    = "10G"
    user         = "ubuntu"
    gt           = "10.0.0.1",
    cidr_prefix  = "24",
  }
}

variable "worker_nodes" {
  default = {
    vm_name      = "worker"
    vm_template  = "ubuntu-2004-cloudinit-template"
    target_node  = "prox"
    cores        = "2"
    sockets      = "1"
    memory       = "3096"
    storage_type = "scsi"
    storage_id   = "QNAP"
    disk_size    = "10G"
    user         = "ubuntu"
    gt           = "10.0.0.1",
    cidr_prefix  = "24",
  }
}

variable "k3s_db_name" {
  default = "k3s"
}

variable "k3s_db_user_name" {
  default = "k3s"
}

resource "random_password" "root-db-password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "random_password" "k3s-master-db-password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "random_password" "k3s-server-token" {
  length           = 32
  special          = false
  override_special = "_%@"
}

variable "control_plane_subnet" {
  default = "10.0.0.0/24"
}

variable "metallb_start_range_ip" {
  default = "10.0.0.65"
}

variable "metallb_end_range_ip" {
  default = "10.0.0.97"
}

variable "master_nodes_count" {
  default = 1
}

variable "workers_nodes_count" {
  default = 2
}

variable "k3s_disable_components" {
  default = ["servicelb"]
}

variable "nfs_server_ip" {
  default = "10.0.0.3"
}

variable "nfs_path" {
  default = "/k8s"
}

variable "letsencrypt_email" {
  default = "yosephbuitrago.01@gmail.com"
}

variable "zone_name" {
  default = "yosephbuitrago.com"
}

variable "tags" {
  default = {
    Env = "homelab"
  }
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "ssh_key" {
  default = "/Users/yosephbuitrago/.ssh/id_rsa.pub"
}

variable "private_ssh_key" {
  default = "/Users/yosephbuitrago/.ssh/id_rsa"
}
