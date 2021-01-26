# variables that can be overriden
variable "host_names"  { default = ["neo", "trinity", "morpheus"] }
variable "domain"      { default = "OCP3.local" }
variable "ip_type"     { default = "static" } # dhcp is other valid type
variable "memoryMB"    { default = 1024*16 }
variable "cpu"         { default = 2 }
variable "prefixIP"    { default = "192.168.200" }
variable "octetIP"     { default = ["70", "80", "90"] }
variable "DockerBytes" { default = 1024*1024*1024*30 }

#variable "cpu"        { default = [4,2,2] }
#variable "memoryMB"    { default = [1024*16, 1024*8, 1024*8] }

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# fetch the latest Redhat release image from their mirrors
resource "libvirt_volume" "os_image" {
  count = length(var.host_names)
  name  = "${var.host_names[count.index]}-os_image"
  pool  = "default"
  source = "/var/lib/libvirt/images/rhel-server-7.8-big-x86_64-kvm.qcow2"
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          count = length(var.host_names)
          name  = "${var.host_names[count.index]}-commoninit.iso"
          pool = "default"
          user_data = data.template_file.user_data.*.rendered[count.index]
          meta_data = data.template_file.meta_data.*.rendered[count.index]
}

# Render cloud init
data "template_file" "user_data" {
  count = length(var.host_names)
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = var.host_names[count.index]
    fqdn = var.domain
  }
}

# Render networking
data "template_file" "meta_data" {
  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  count = length(var.octetIP)
  vars = {
    domain = var.domain
    prefixIP = var.prefixIP
    LastOCT  = var.octetIP[count.index]
  }

}

# Render extra data disk for Docker
resource "libvirt_volume" "disk_data1" {
  count = length(var.host_names)
  name           = "${var.host_names[count.index]}-docker"
  pool           = "default"
  size           = var.DockerBytes
  format         = "qcow2"
}

# Create the machine
resource "libvirt_domain" "domain-RHEL" {
  # domain name in libvirt, not hostname
  count = length(var.host_names)
  name = "${var.host_names[count.index]}-${var.domain}"
  memory = var.memoryMB
  vcpu = var.cpu

#  memory = var.memoryMB[count,index]
#  vcpu = var.cpu[count,index]

  disk { volume_id = libvirt_volume.os_image[count.index].id   }
  disk { volume_id = libvirt_volume.disk_data1[count.index].id }

  network_interface {
       network_name = "General"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  # IMPORTANT
  # RHEL can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

terraform { 
  required_version = ">= 0.12"
}
