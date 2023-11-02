# === Bastion host ===
resource "yandex_compute_instance" "bastion" {
  name     = "bastion"
  hostname = "bastion"
  zone     = "ru-central1-a"
  

  scheduling_policy {
    preemptible = true
  }

  resources {
  # core_fraction = 20
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-main["subnet-1"].id
    security_group_ids = [yandex_vpc_security_group.sg-bastion.id]

    ip_address         = "192.168.10.100"
    nat                = true
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}






# === web servers ===

resource "yandex_compute_instance" "web1" {
  name     = "web1"
  hostname = "web1"
  zone     = "ru-central1-a"
  

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-main["subnet-1"].id
    security_group_ids = [yandex_vpc_security_group.sg-ssh.id, yandex_vpc_security_group.sg-webserv.id]
    ip_address         = "192.168.10.10"
    #nat                = false
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}




resource "yandex_compute_instance" "web2" {
  name     = "web2"
  hostname = "web2"
  zone     = "ru-central1-b"
  

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-main["subnet-2"].id
    security_group_ids = [yandex_vpc_security_group.sg-ssh.id, yandex_vpc_security_group.sg-webserv.id]
    ip_address         = "192.168.20.10"
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}






# === Zabbix ===
resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix"
  zone = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main["subnet-1"].id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.sg-ssh.id, yandex_vpc_security_group.sg-zabbix.id]
    ip_address         = "192.168.10.110"
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}





# === ElasticSearch ===
resource "yandex_compute_instance" "elastic" {

  name = "elastic"
  hostname = "elastic"
  zone = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main["subnet-1"].id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.sg-elastic.id, yandex_vpc_security_group.sg-ssh.id]
    ip_address         = "192.168.10.111"
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}



# === Kibana ===
resource "yandex_compute_instance" "kibana" {

  name = "kibana"
  hostname = "kibana"
  zone = "ru-central1-a"

  scheduling_policy {
    preemptible = true
  }

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd87gocdmk3tosg6onpg"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-main["subnet-1"].id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.sg-kibana.id, yandex_vpc_security_group.sg-ssh.id]
    ip_address         = "192.168.10.112"
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }
}
