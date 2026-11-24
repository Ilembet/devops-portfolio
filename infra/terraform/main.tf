locals {
  subnet_cidrs = { for idx, zone in var.zones : zone => cidrsubnet("10.10.0.0/16", 8, idx) }
  ssh_key      = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

resource "yandex_vpc_network" "main" {
  name = "portfolio-net"
}

resource "yandex_vpc_subnet" "zone" {
  for_each = toset(var.zones)

  name           = "portfolio-${each.value}"
  zone           = each.value
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [local.subnet_cidrs[each.value]]
}

resource "yandex_vpc_security_group" "vm" {
  name       = "portfolio-vm"
  network_id = yandex_vpc_network.main.id

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description    = "notes-api"
    protocol       = "TCP"
    port           = 8000
    v4_cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "vm" {
  for_each = yandex_vpc_subnet.zone

  name        = "${var.name_prefix}-${each.key}"
  hostname    = "${var.name_prefix}-${each.key}"
  zone        = each.key
  platform_id = "standard-v3"

  resources {
    cores         = var.vm_cores
    memory        = var.vm_memory_gb
    core_fraction = var.vm_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = each.value.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vm.id]
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  # First boot: create the ubuntu user, install Docker, start notes-api from GHCR
  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      ssh_key     = local.ssh_key
      compose_b64 = base64encode(file("${path.module}/../../projects/notes-api/deploy/docker-compose.yml"))
    })
  }
}
