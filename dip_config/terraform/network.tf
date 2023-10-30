# === Сети и подсети ===

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-main" {
  for_each = {
    for k, v in local.subnet_array : "${v.name}" => v
  }
  network_id = yandex_vpc_network.network-1.id
  route_table_id = yandex_vpc_route_table.route-table.id

  v4_cidr_blocks = each.value.cidr
  zone           = each.value.zone
  name           = each.value.name
}


# === nat ===

resource "yandex_vpc_gateway" "nat-gw" {
  name = "nat-gw"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route-table" {
  name       = "route-table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id = yandex_vpc_gateway.nat-gw.id
  }
}


# === Target Group ===

resource "yandex_alb_target_group" "target-group" {
  name      = "target-group"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-main["subnet-1"].id}"
    ip_address   = "${yandex_compute_instance.web1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-main["subnet-2"].id}"
    ip_address   = "${yandex_compute_instance.web2.network_interface.0.ip_address}"
  }
}


# === Backend Group ===

resource "yandex_alb_backend_group" "backend-group" {
  name      = "backend-group"

  http_backend {
    name = "backend-group"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.target-group.id}"]
    healthcheck {
      timeout = "10s"
      interval = "2s"
      healthy_threshold = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path  = "/"
      }
    }
  }
}

# === HTTP Router ===

resource "yandex_alb_http_router" "http-router" {
  name      = "http-router"
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name      = "virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout = "60s"
      }
    }
  }
}

# === Application Load Balancer ===

resource "yandex_alb_load_balancer" "load-balancer" {
  name        = "load-balancer"

  network_id  = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.security-public-alb.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-main["subnet-1"].id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-main["subnet-2"].id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}






# === Security groups ===

# --- Bastion ---

resource "yandex_vpc_security_group" "sg-bastion" {
  name        = "sg-bastion"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Вход от zabbix"
    port           = 10050
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]  
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}


# --- ssh traffic ---

resource "yandex_vpc_security_group" "sg-ssh" {
  name        = "sg-ssh"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }
}




# --- Load Balancer ---

resource "yandex_vpc_security_group" "security-public-alb" {
  name        = "security-public-alb"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}




# --- webservers ---

resource "yandex_vpc_security_group" "sg-webserv" {
  name           = "sg-webserv"
  network_id     = yandex_vpc_network.network-1.id
  
  ingress {
    protocol       = "TCP"
    description    = "Вход для http"
    port           = 80
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Вход от zabbix"
    port           = 10050
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]  
  }

  egress {
    protocol       = "ANY"
    description    = "Исходящие не ограничиваем"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}





# --- Zabbix ---

resource "yandex_vpc_security_group" "sg-zabbix" {
  name       = "sg-zabbix"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "Вход веб-интерфейса"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Входящий от zabbix-agent'ов"
    port           = 10051
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}



# --- ElasticSearch ---

resource "yandex_vpc_security_group" "sg-elastic" {
  name        = "sg-elastic"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "Входящий для elastic"
    port           = 9200
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Вход от zabbix"
    port           = 10050
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]  
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}


# --- Kibana ---

resource "yandex_vpc_security_group" "sg-kibana" {
  name        = "sg-kibana"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "Входящий для веб-интерфейса"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Вход от zabbix"
    port           = 10050
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]  
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}