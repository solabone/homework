resource "yandex_vpc_network" "develop" {
  name = "develop-fops-${var.flow}"
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-fops-${var.flow}-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

resource "yandex_vpc_security_group" "LAN" {
  name        = "sg-LAN-${var.flow}"
  network_id  = yandex_vpc_network.develop.id
  description = "Внутренний трафик"

  ingress {
    protocol       = "ANY"
    description    = "Разрешить весь входящий от подсети"
    v4_cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Разрешить весь исходящий"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "public" {
  name        = "sg-public-${var.flow}"
  network_id  = yandex_vpc_network.develop.id
  description = "Доступ извне: SSH, Jenkins, Nexus"

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Jenkins UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  ingress {
    protocol       = "TCP"
    description    = "Nexus UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8081
  }

  ingress {
    protocol       = "TCP"
    description    = "Nexus Docker registry"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8082
  }

  egress {
    protocol       = "ANY"
    description    = "Разрешить весь исходящий"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
