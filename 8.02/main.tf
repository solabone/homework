//
// Create a new Compute Instance
//
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "jenkins" {
  name        = "jenkins"
  hostname = "jenkins"
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
    nat       = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.public.id]
  }
}
