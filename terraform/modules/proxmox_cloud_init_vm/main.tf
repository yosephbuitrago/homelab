
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.6"
    }
  }
}


resource "proxmox_vm_qemu" "vm" {
  name        = var.vm_name
  target_node = var.vm_settings.target_node
  clone       = var.vm_settings.vm_template
  full_clone  = true
  agent       = 1
  os_type     = "cloud-init"
  cores       = var.vm_settings.cores
  sockets     = var.vm_settings.sockets
  cpu         = "host"
  memory      = var.vm_settings.memory
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  disk {
    slot     = 0
    size     = var.vm_settings.disk_size
    type     = var.vm_settings.storage_type
    storage  = var.vm_settings.storage_id
    iothread = 1
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  ipconfig0 = "ip=${var.vm_ip}/${var.vm_settings.cidr_prefix},gw=${var.vm_settings.gt}"
  sshkeys   = var.ssh_key
  ciuser    = var.vm_settings.user
  connection {
    type        = "ssh"
    user        = var.vm_settings.user
    host        = var.vm_ip
    private_key = var.private_ssh_key
  }
  provisioner "remote-exec" {
    inline = var.inline
  }
  lifecycle {
    ignore_changes = [
      network,
      disk
    ]
  }
}