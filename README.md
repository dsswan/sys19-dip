# Дипломная работа профессии Системный администратор - Лебедев Д.С.

---
В соответствии с заданием была разработана отказоустойчивая инфраструктура для сайта, включающая мониторинг, сбор логов и резервное копирование основных данных.
#### Для создания инфраструктуры системы в Yandex Cloud (YC) используется ПО Terraform. Основные этапы:
- Создание виртуальных машин (ВМ) для http веб-серверов, идентичных, расположенных в разных зонах;
- Создание отказоустойчивой инфраструктуры для сайта, а именно: Target и Backend групп, http роутера, балансировщика нагрузки для веб-серверов;
- Настроена сеть, с подсетями в разных зонах, и с соответствующими группами безопасности для ВМ и сервисов;
- Созданы ВМ для организации систем мониторинга (Zabbix через zabbix-agent) и сбора лог-файлов с ВМ (Elasticsearch через Filebeat + сервер Kibana);
- Организовано резервное копирование данных, путём снятия snapshot дисков всех ВМ с определённой периодичностью.
#### Для настройки созданных ВМ используется ПО Ansible. Основные этапы:
- Установка и первоначальная настройка http серверов;
- Установка и настройка сервера сбора логов Elasticsearch;
- Установка и настройка системы визуализации данных Kibana;
- Установка на соответствующих ВМ плагина для сбора и передачи логов Filebeat;
- Установка и первоначальная настройка сервера системы мониторинга Zabbix;
- Установка и настройка zabbix-agent для мониторинга ВМ инфраструктуры.

---
#### 1. Terraform. Создание инфраструктуры.
1.1. Конфигурационный файл main.tf описывает провайдера и параметры подключения, ссылается на файл с описанием переменных variables.tf и  использует файл переменных terraform.tfvars. Так же файлы variables.tf, terraform.tfvars и locals.tf используются для создания подсетей (subnet) с помощью цикла for_each.

```bash
main.tf
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
	  token     = var.token_id
	  cloud_id  = var.cloud_id
	  folder_id = var.folder_id
	  zone      = var.default_zone
	}
```

```bash
variables.tf
	#=========== main ==============
	variable "token_id" {
	  description = "The token"
	  type        = string
	}
	variable "cloud_id" {
	  description = "The cloud ID"
	  type        = string
	}
	variable "folder_id" {
	  description = "The folder ID"
	  type        = string
	}
	variable "default_zone" {
	  description = "The default zone"
	  type        = string
	  default     = "ru-cenral1-a"
	}
	
	
	#=========== subnet ==============
	variable "subnets" {
	  description = "Subnets for www cluster"
	
	  type = map(list(object(
	    {
	      name = string,
	      zone = string,
	      cidr = list(string)
	    }))
	  )
	}
```

```bash
terraform.tfvars
	#=========== main ==============
	token_id  = "y0_AgAAAA.."
	cloud_id  = "b1g31l99..."
	folder_id = "b1g5412..."
	
	#=========== subnet ==============
	subnets = {
	  "subnets" = [
	    {
	      name = "subnet-1"
	      zone = "ru-central1-a"
	      cidr = ["192.168.10.0/24"]
	    },
	    {
	      name = "subnet-2"
	      zone = "ru-central1-b"
	      cidr = ["192.168.20.0/24"]
	    },
	    {
	      name = "subnet-3"
	      zone = "ru-central1-c"
	      cidr = ["192.168.30.0/24"]
	    }
	  ]
	}
```

```bash
locals.tf
	locals {
	  subnet_array = flatten([for k, v in var.subnets : [for j in v : {
	    name = j.name
	    zone = j.zone
	    cidr = j.cidr
	    }
	  ]])
	}
```




<details>
<summary>main.tf</summary>

```bash
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
  token     = var.token_id
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}
```

</details>