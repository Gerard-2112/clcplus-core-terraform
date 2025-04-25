locals {
  infra-ips-els = range(var.instances.infra.count)
}

data "local_file" "id_rsa_pub" {
  filename = "../control/.ssh/id_rsa.pub"
}

resource "openstack_compute_keypair_v2" "id_rsa" {
  name       = "control"
  public_key = data.local_file.id_rsa_pub.content
}

data "template_file" "user_data" {
  template = <<EOF
#cloud-config
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2WWEB/M88eWnMR8HB8wwAUcxXTi5VXeegcJ79B7Mn65jH3xmltVsbj/1feOZXYGxjh6ghMRadgvb+jvCcrNsDgndRf/cDJE87CMmlqzpzl5XwSPrtsgY4rHvuvGkVjuX0sW3QbBfzYeNi5pVtWKX7ItANbBKoy6753nSvzpRaNqu0eJfpA1zUgbryTJIqNF7fR5sLYLSCR53R6xZ0w6LZxiTaOtecqL4E/pC2SFXGlXHILMJvJrpaIxw4P7JQ/vC9YuL1biViQJAwinSSqUNLok6QZnd6ugfjphgvlwZ2gModOmY/LmYT4pO9STZZ6PwxQ44mreejIfh2e+RIHmFN jenglisch@jenglisch-Catalysts
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOuQldPaf83WlU/WIVvMR4/uyvsAqVARm4ON2pJ+/u9sNDvl9O2yD7ChgmlkJV3hVRf9n0HcSqO2MbDbbWaoZIUFRhQgQpYdyQamYTxkqUX18W1YXAPbDHo2vtSdXOFi0UfxwzBqkIHsEAm+Emz7so2SjWIyt/EyKZhoJkLWFQRruakjLlTKG4DqHW2RoRuh3Oe39c9N9Wjoo0sWvtERdG0hp0xR5wx28rJDGNPQ1SGh/xUFMp4d7kt5pV2/GlAr89XpOQrBz/oNC4x/zV/vi9CEl1Tf9vMswiUW18PuaE8J/d1+SvMM1vahK3BVoSKymsgmIyIsCBsq02fvTq9pkZ mstrigl@mstrigl-pc.localdomain
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD80Z7vg9jK5x0dLJl8mLRd3kMwotF3GK/EY8FBJSBBESWVuw8CIl85a59sS65lT5buwpdLc5qIe9/LTvpRrh1lDDg7bKsASTvVbuLRe0oygTxNVAKuornyTcS/QZtbhmiYfIxCcvepf04bej9N7rtP3dnmKGnD9LGVRnTFKJUMtv8IKmhg1xpgimD4zW+fS85uGdoV8qXa0Hd/zIE3SExmy54mThlWfoaJ5R28XkFS0nCTFk2h/Zf9LG4twc4GyAjiei6eZIFRoUVNzF1+zzALRwol7gK2JJaJj4Or+tGAQfHtj0DTH8WX0Uy/sLtXtmL7B4TDv4dLY4fBYlpi5pMQyTeGKw84vfh4sqXNfBh0y8oiGVN6NhH0X33uis4ikTzwofqlBqEl9eBch2lTx3UtBS6JMxj+imCvrCjaKWZ9kQYhc7pgpGeGlk2/8zGY/4pSqsISFpAvoua1+hWZObs0QeQWG30PNw0Evn7+BuSHcVEOWwFFUqzT22FvUk7P+Ys= tobias.stahn@cloudflight.io
EOF

}

// ******************** CONTROL ********************
resource "openstack_blockstorage_volume_v3" "control" {
  name          = format("control")
  size          = var.instances["control"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "control" {
  name           = "control"
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.control.id

  security_groups = [
    openstack_networking_secgroup_v2.control.name
  ]

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.control.id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, var.instances["control"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

resource "openstack_compute_floatingip_associate_v2" "control" {
  floating_ip = openstack_networking_floatingip_v2.control.address
  instance_id = openstack_compute_instance_v2.control.id

  depends_on = [openstack_networking_router_interface_v2.external-router]
}

// ******************** INFRA ********************
resource "openstack_compute_servergroup_v2" "infra" {
  name     = "infra"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "infra" {
  count         = var.instances["infra"].count
  name          = format("infra%02d", count.index + 1)
  size          = var.instances["infra"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "infra" {
  count     = var.instances["infra"].count
  name      = format("infra%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.infra.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.infra.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.infra.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.infra[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["infra"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]

}

resource "openstack_compute_floatingip_associate_v2" "infra" {
  floating_ip = openstack_networking_floatingip_v2.infra.address
  instance_id = openstack_compute_instance_v2.infra[0].id

  depends_on = [openstack_networking_router_interface_v2.external-router]
}

// ******************** SUPINFRA ********************
resource "openstack_compute_servergroup_v2" "supinfra" {
  name     = "supinfra"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "supinfra" {
  count         = var.instances["supinfra"].count
  name          = format("supinfra%02d", count.index + 1)
  size          = var.instances["supinfra"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "supinfra" {
  count     = var.instances["supinfra"].count
  name      = format("supinfra%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.supinfra.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.supinfra.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.supinfra.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.supinfra[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["supinfra"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

// ******************** APPLIKATION ********************
resource "openstack_compute_servergroup_v2" "applikation" {
  name     = "applikation"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "applikation" {
  count         = var.instances["applikation"].count
  name          = format("applikation%02d", count.index + 1)
  size          = var.instances["applikation"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "applikation" {
  count     = var.instances["applikation"].count
  name      = format("applikation%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.applikation.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.applikation.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.applikation.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.applikation[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["applikation"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

// ******************** GEOSERVER ********************
resource "openstack_compute_servergroup_v2" "geoserver" {
  name     = "geoserver"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "geoserver" {
  count         = var.instances["geoserver"].count
  name          = format("geoserver%02d", count.index + 1)
  size          = var.instances["geoserver"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "geoserver" {
  count     = var.instances["geoserver"].count
  name      = format("geoserver%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.geoserver.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.geoserver.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.geoserver.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.geoserver[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["geoserver"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

// ******************** GRIDMAPPERWORKER ********************
resource "openstack_compute_servergroup_v2" "gridmapperworker" {
  name     = "gridmapperworker"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "gridmapperworker" {
  count         = var.instances["gridmapperworker"].count
  name          = format("gridmapperworker%02d", count.index + 1)
  size          = var.instances["gridmapperworker"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "gridmapperworker" {
  count     = var.instances["gridmapperworker"].count
  name      = format("gridmapperworker%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.gridmapperworker.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.gridmapperworker.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.gridmapperworker.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.gridmapperworker[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["gridmapperworker"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

// ******************** SPARCWORKER ********************
resource "openstack_compute_servergroup_v2" "sparcworker" {
  name     = "sparcworker"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "sparcworker" {
  count         = var.instances["sparcworker"].count
  name          = format("sparcworker%02d", count.index + 1)
  size          = var.instances["sparcworker"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "sparcworker" {
  count     = var.instances["sparcworker"].count
  name      = format("sparcworker%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.sparcworker.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.sparcworker.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.sparcworker.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.sparcworker[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["sparcworker"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}

// ******************** SPARCPREVIEWWORKER ********************
resource "openstack_compute_servergroup_v2" "sparcpreviewworker" {
  name     = "sparcpreviewworker"
  policies = ["anti-affinity"]
}

resource "openstack_blockstorage_volume_v3" "sparcpreviewworker" {
  count         = var.instances["sparcpreviewworker"].count
  name          = format("sparcpreviewworker%02d", count.index + 1)
  size          = var.instances["sparcpreviewworker"].volsize
  volume_type   = "SSD"
  image_id      = data.openstack_images_image_v2.default.id
}

resource "openstack_compute_instance_v2" "sparcpreviewworker" {
  count     = var.instances["sparcpreviewworker"].count
  name      = format("sparcpreviewworker%02d", count.index + 1)
  key_pair  = openstack_compute_keypair_v2.id_rsa.name
  user_data = data.template_file.user_data.rendered
  flavor_id = data.openstack_compute_flavor_v2.sparcpreviewworker.id

  security_groups = [
    "default",
    openstack_networking_secgroup_v2.node.name,
    openstack_networking_secgroup_v2.sparcpreviewworker.name,
  ]

  scheduler_hints {
    group = openstack_compute_servergroup_v2.sparcpreviewworker.id
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.sparcpreviewworker[count.index].id
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    uuid        = openstack_networking_network_v2.default.id
    fixed_ip_v4 = cidrhost(var.network, count.index + var.instances["sparcpreviewworker"].cidrstart)
  }

  depends_on = [openstack_networking_subnet_v2.default]
}
