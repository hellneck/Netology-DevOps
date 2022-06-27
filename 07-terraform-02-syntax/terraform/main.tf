provider "yandex" {
  cloud_id                 = "b1gc188g6h91cqb27afs"
  folder_id                = "b1gsiqjc15uk1djoft66"
  zone                     = "ru-central1-a"
}

data "yandex_iam_user" "admin" {
  login   = "hellneck"
}

data "yandex_iam_service_account" "admin" {
  name = "hellneck"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_image" "ubuntu-20_04" {
  name          = "ubuntu2004"
  source_image  = "${data.yandex_compute_image.ubuntu.id}"
}

resource "yandex_compute_instance" "netology" {
  name                      = "netology"
  zone                      = "ru-central1-a"
  hostname                  = "netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id    = "${yandex_compute_image.ubuntu-20_04.id}"
      name        = "root-netology"
      type        = "network-nvme"
      size        = "10"
    }
  }

  network_interface {
    subnet_id  = "${yandex_vpc_subnet.default.id}"
    nat        = true
    ip_address = "192.168.100.100"
  }
}

resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.100.0/24"]
}

