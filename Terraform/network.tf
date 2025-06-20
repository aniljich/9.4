resource "yandex_vpc_network" "cloud" {
  name = "cloud-network"
}

resource "yandex_vpc_subnet" "cloud-a" {
  name           = "cloud-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.cloud.id
  v4_cidr_blocks = ["10.0.1.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "cloud-gateway" {
  name = "cloud-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "cloud-route-table"
  network_id = yandex_vpc_network.cloud.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.cloud-gateway.id
  }
}