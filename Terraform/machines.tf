data "yandex_compute_image" "ubuntu-noble" {
  family = "ubuntu-2404-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  metadata = {
    user-data = file("./cloud-init-bastion.yml")
  }

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-noble.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.cloud-a.id
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "web" {

  count = var.web_server_count

  name        = "web${count.index}"
  hostname    = "web${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  metadata = {
    user-data = file("./cloud-init-web.yml")
  }

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-noble.image_id
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.cloud-a.id
    security_group_ids = [yandex_vpc_security_group.web.id, yandex_vpc_security_group.LAN.id]
  }

  scheduling_policy {
    preemptible = true
  }
}
