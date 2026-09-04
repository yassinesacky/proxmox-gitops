terraform {
    required_providers {
        proxmox = {
            source  = "bpg/proxmox"
            version = "~> 9.2.2"
        }
    }
}
# proxmox provider configs 

provider "proxmox" {
  endpoint = "https://100.119.241.73:8006/"
  api_token = "root@pam!gitops=efc2ea39-3449-4ce6-bd47-91b549c3b14d"
  insecure = true

}

# --------------------------------------------------
# Download Ubuntu LXC Template
# --------------------------------------------------

resource "proxmox_virtual_environment_download_file" "ubuntu_template" {

  content_type = "vztmpl"

  datastore_id = "local"

  node_name = "pve"

  url = "https://download.proxmox.com/images/system/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}


# --------------------------------------------------
# Create LXC Container
# --------------------------------------------------

resource "proxmox_virtual_environment_container" "lxc_test" {

  description = "Terraform managed LXC"

  node_name = "pve"

  vm_id = 101


  # -----------------------------------------------
  # Container settings
  # -----------------------------------------------

  unprivileged = true

  features {
    nesting = true
  }

  cores = 1

  memory {
    dedicated = 512
  }


  # -----------------------------------------------
  # Container hostname + user
  # -----------------------------------------------

  initialization {

    hostname = "terraform-lxc"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      password = "ChangeMe123!"
    }
  }


  # -----------------------------------------------
  # Network
  # -----------------------------------------------

  network_interface {

    name = "eth0"

    bridge = "vmbr0"
  }


  # -----------------------------------------------
  # Root filesystem
  # -----------------------------------------------

  disk {

    datastore_id = "local-lvm"

    size = 4
  }


  # -----------------------------------------------
  # Ubuntu operating system
  # -----------------------------------------------

  operating_system {

    template_file_id = proxmox_virtual_environment_download_file.ubuntu_template.id

    type = "ubuntu"
  }


  # -----------------------------------------------
  # Start container automatically
  # -----------------------------------------------

  started = true

  start_on_boot = true
}


# --------------------------------------------------
# Output
# --------------------------------------------------

output "container_id" {

  value = proxmox_virtual_environment_container.lxc_test.vm_id
}

output "container_ipv4" {

  value = proxmox_virtual_environment_container.lxc_test.ipv4
}

 