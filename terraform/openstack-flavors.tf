data "openstack_compute_flavor_v2" "control" {
  name = var.instances["control"].flavor
}

data "openstack_compute_flavor_v2" "infra" {
  name = var.instances["infra"].flavor
}

data "openstack_compute_flavor_v2" "supinfra" {
  name = var.instances["supinfra"].flavor
}

data "openstack_compute_flavor_v2" "applikation" {
  name = var.instances["applikation"].flavor
}

data "openstack_compute_flavor_v2" "geoserver" {
  name = var.instances["geoserver"].flavor
}

data "openstack_compute_flavor_v2" "gridmapperworker" {
  name = var.instances["gridmapperworker"].flavor
}

data "openstack_compute_flavor_v2" "sparcworker" {
  name = var.instances["sparcworker"].flavor
}

data "openstack_compute_flavor_v2" "sparcpreviewworker" {
  name = var.instances["sparcpreviewworker"].flavor
}
