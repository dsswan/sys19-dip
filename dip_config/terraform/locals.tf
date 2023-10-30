locals {
  subnet_array = flatten([for k, v in var.subnets : [for j in v : {
    name = j.name
    zone = j.zone
    cidr = j.cidr
    }
  ]])
}