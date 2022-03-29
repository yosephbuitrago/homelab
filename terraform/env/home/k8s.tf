locals {
  mariadb_vm_ip     = cidrhost(var.control_plane_subnet, 33)
  master_node_ips   = [for i in range(var.master_nodes_count) : cidrhost(var.control_plane_subnet, i + 34)]
  workers_nodes_ips = [for i in range(var.workers_nodes_count) : cidrhost(var.control_plane_subnet, i + 38)]
  k3s_server_hosts  = [for ip in local.master_node_ips : "${ip}:6443"]
}

module "mariadb" {
  source          = "../../modules/proxmox_cloud_init_vm"
  vm_name         = var.mariadb.vm_name
  vm_settings     = var.mariadb
  vm_ip           = local.mariadb_vm_ip
  ssh_key         = file(var.ssh_key)
  private_ssh_key = file(var.private_ssh_key)
  inline = [
    templatefile("../../tpl/install-support-apps.sh.tftpl", {
      root_password = random_password.root-db-password.result
      k3s_database  = var.k3s_db_name
      k3s_user      = var.k3s_db_user_name
      k3s_password  = random_password.k3s-master-db-password.result
    })
  ]
  depends_on = [
    module.route53_homelab
  ]
}

resource "null_resource" "mariadb" {

  depends_on = [
    module.mariadb
  ]

  triggers = {
    config_change = filemd5("../../tpl/nginx.conf.tftpl")
  }

  connection {
    type        = "ssh"
    user        = var.mariadb.user
    host        = local.mariadb_vm_ip
    private_key = file(var.private_ssh_key)
  }

  provisioner "file" {
    destination = "/tmp/nginx.conf"
    content = templatefile("../../tpl/nginx.conf.tftpl", {
      k3s_server_hosts = [for ip in local.master_node_ips :
        "${ip}:6443"
      ]
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx.service",
    ]
  }
}

module "k3s_master_nodes" {
  count           = length(local.master_node_ips)
  source          = "../../modules/proxmox_cloud_init_vm"
  vm_name         = "${var.master_nodes.vm_name}${count.index + 1}"
  vm_settings     = var.master_nodes
  vm_ip           = local.master_node_ips["${count.index}"]
  ssh_key         = file(var.ssh_key)
  private_ssh_key = file(var.private_ssh_key)
  inline = [
    templatefile("../../tpl/install-k3s-server.sh.tftpl", {
      mode         = "server"
      tokens       = [nonsensitive(random_password.k3s-server-token.result)]
      alt_names    = [local.mariadb_vm_ip]
      server_hosts = []
      node_taints  = ["CriticalAddonsOnly=true:NoExecute"]
      disable      = var.k3s_disable_components
      datastores = [{
        host     = "${local.mariadb_vm_ip}:3306"
        name     = var.k3s_db_name
        user     = var.k3s_db_user_name
        password = nonsensitive(random_password.k3s-master-db-password.result)
      }]
    }),
    "sudo apt install jq nfs-common -y",
  ]
  depends_on = [
    module.route53_homelab,
    module.mariadb
  ]
}


module "k3s_workers_nodes" {
  count           = length(local.workers_nodes_ips)
  source          = "../../modules/proxmox_cloud_init_vm"
  vm_name         = "${var.worker_nodes.vm_name}${count.index + 1}"
  vm_settings     = var.worker_nodes
  vm_ip           = local.workers_nodes_ips["${count.index}"]
  ssh_key         = file(var.ssh_key)
  private_ssh_key = file(var.private_ssh_key)
  inline = [
    templatefile("../../tpl/install-k3s-server.sh.tftpl", {
      mode         = "agent"
      tokens       = [nonsensitive(random_password.k3s-server-token.result)]
      alt_names    = []
      disable      = []
      server_hosts = ["https://${local.mariadb_vm_ip}:6443"]
      node_taints  = []
      datastores   = []
    }),
    "sudo apt install jq nfs-common -y"
  ]

  depends_on = [
    module.route53_homelab,
    module.mariadb,
    module.k3s_master_nodes
  ]
}


resource "null_resource" "cluster_config" {

  depends_on = [
    module.k3s_workers_nodes
  ]

  triggers = {
    config_change = filemd5("../../tpl/cluster-config.sh.tftpl")
  }

  connection {
    type        = "ssh"
    user        = var.mariadb.user
    host        = local.master_node_ips[0]
    private_key = file(var.private_ssh_key)
  }

  provisioner "file" {
    destination = "/tmp/cluster-config.sh"
    content = templatefile("../../tpl/cluster-config.sh.tftpl", {
      start_range_ip                 = var.metallb_start_range_ip
      end_range_ip                   = var.metallb_end_range_ip
      nfs_server_ip                  = var.nfs_server_ip
      nfs_path                       = var.nfs_path
      external_dns_key_id            = module.route53_homelab.external_dns_key_id
      external_dns_secret_access_key = nonsensitive(module.route53_homelab.external_dns_secret_access_key)
      cert_manager_access_key        = module.route53_homelab.cert_manager_secret_access_key
      cert_manager_key_id            = module.route53_homelab.cert_manager_key_id
      letsencrypt_email              = var.letsencrypt_email
      zone_name                      = module.route53_homelab.zone_name
      aws_region                     = var.aws_region
    })
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/cluster-config.sh",
      "/tmp/cluster-config.sh",
    ]
  }
}