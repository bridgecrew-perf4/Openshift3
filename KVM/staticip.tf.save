# variables that can be overriden
variable "hostname"    { default = "testmaster" }
variable "domain"      { default = "OCP3.local" }
variable "ip_type"     { default = "static" } # dhcp is other valid type
variable "memoryMB"    { default = 1024*16 }
variable "cpu"         { default = 4 }
variable "prefixIP"    { default = "192.168.200" }
variable "octetIP"     { default = "70" }
variable "DockerBytes" { default = 1024*1024*1024*30 }

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
  name = "${var.hostname}-os_image"
  pool = "default"
#  source = "/var/lib/libvirt/images/rhel-server-7.8-x86_64-kvm.qcow2"
  source = "/var/lib/libvirt/images/rhel-server-7.8-big-x86_64-kvm.qcow2"
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          name = "${var.hostname}-commoninit.iso"
          pool = "default"
          user_data = data.template_file.user_data.rendered
          meta_data = data.template_file.meta_data.rendered
}


data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
  }
}

data "template_file" "meta_data" {
  template = file("${path.module}/network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.domain
    prefixIP = var.prefixIP
    octetIP = var.octetIP
  }
}

# extra data disk for Pulp xfs
resource "libvirt_volume" "disk_data1" {
  name           = "${var.hostname}-pulp-xfs"
  pool           = "default"
  size           = var.DockerBytes
  format         = "qcow2"
}


# Create the machine
resource "libvirt_domain" "domain-RHEL" {
  # domain name in libvirt, not hostname
  name = "${var.hostname}-${var.domain}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk { volume_id = libvirt_volume.os_image.id   }
  disk { volume_id = libvirt_volume.disk_data1.id }

  network_interface {
       network_name = "General"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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
