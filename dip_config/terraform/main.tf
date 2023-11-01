terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


# Описание провайдера YC
provider "yandex" {
  service_account_key_file = "${file("~/authorized_key.json")}"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}