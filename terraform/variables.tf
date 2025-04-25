variable "network" {
  default = "192.168.199.0/24"
}

variable "instances" {
  default = {
    control             = { count = 1 , cidrstart = 10  , flavor = "eo1.xmedium" , volsize = 20   }
    infra               = { count = 1 , cidrstart = 21  , flavor = "hma.medium"  , volsize = 200  }
    supinfra            = { count = 1 , cidrstart = 41  , flavor = "hma.large"    , volsize = 1000 }
    applikation         = { count = 1 , cidrstart = 51  , flavor = "hma.large"    , volsize = 200  }
    geoserver           = { count = 1 , cidrstart = 71  , flavor = "hma.large"    , volsize = 200  }
    gridmapperworker    = { count = 3 , cidrstart = 91  , flavor = "hma.large"    , volsize = 300  }
    sparcworker         = { count = 2 , cidrstart = 131 , flavor = "hma.large"    , volsize = 100  }
    sparcpreviewworker  = { count = 1 , cidrstart = 141 , flavor = "hma.large"    , volsize = 100  }
  }
}
