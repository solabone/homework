//
// Create a new Compute Instance
//
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = var.test.cores
    memory = var.test.memory
    core_fraction = var.test.core_fraction
  }

  boot_disk {
    initialize_params {
        image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
        type = "network-hdd"
        size = 10      
    }
    
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.bastion.id]
  }
}

resource "yandex_compute_instance" "web_a" {
  name        = "web-a"
  hostname = "web-a"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = var.test.cores
    memory = var.test.memory
    core_fraction = var.test.core_fraction
  }

  boot_disk {
    initialize_params {
        image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
        type = "network-hdd"
        size = 10      
    }
    
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat = false
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}

resource "yandex_compute_instance" "web_b" {
  name        = "web-b"
  hostname = "web-b"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = var.test.cores
    memory = var.test.memory
    core_fraction = var.test.core_fraction
  }

  boot_disk {
    initialize_params {
        image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
        type = "network-hdd"
        size = 10      
    }
    
  }

  metadata = {
    user-data = file("./cloud-init.yml")
    serial-port-enable = 1
  }
  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat = false
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}

resource "local_file" "inventory" {
  content = <<-XYZ
  [bastion]
  ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} ansible_user=soldatov

  [webservers]
  ${yandex_compute_instance.web_a.network_interface.0.ip_address} ansible_user=soldatov
  ${yandex_compute_instance.web_b.network_interface.0.ip_address} ansible_user=soldatov

  [webservers:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q soldatov@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'
  XYZ
  filename = "./hosts.ini"
}