#=========== main ==============
token_id  = "y0_AgAAAAAE7VMoAATuwQAAAADhfojTCMjOLAAAQ1iuBmYD4eRCrbIdRyk"
cloud_id  = "b1g31l9912a5snugc28a"
folder_id = "b1g5412cb8jjfmnc09pb"

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