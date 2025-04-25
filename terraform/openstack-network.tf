locals {
}

resource "openstack_networking_network_v2" "default" {
  name           = "default"
  admin_state_up = "true"
}

data "openstack_networking_network_v2" "external" {
  name       = "external"
  network_id = "22d18510-faec-4d77-974b-ce4f16825b20"
}

resource "openstack_networking_subnet_v2" "default" {
  name       = "default"
  network_id = openstack_networking_network_v2.default.id
  cidr       = var.network
  ip_version = 4
}

resource "openstack_networking_router_v2" "external" {
  name                = "external"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_floatingip_v2" "control" {
  pool        = "external"
  description = "control"
}

resource "openstack_networking_floatingip_v2" "infra" {
  pool           = "external"
  description    = "infra-ip"
}

resource "openstack_networking_router_interface_v2" "external-router" {
  router_id = openstack_networking_router_v2.external.id
  subnet_id = openstack_networking_subnet_v2.default.id
}

resource "openstack_networking_secgroup_v2" "control" {
  name = "control"
}

resource "openstack_networking_secgroup_v2" "node" {
  name = "node"
}

resource "openstack_networking_secgroup_v2" "infra" {
  name = "infra"
}

resource "openstack_networking_secgroup_v2" "supinfra" {
  name = "supinfra"
}

resource "openstack_networking_secgroup_v2" "applikation" {
  name = "applikation"
}

resource "openstack_networking_secgroup_v2" "geoserver" {
  name = "geoserver"
}

resource "openstack_networking_secgroup_v2" "gridmapperworker" {
  name = "gridmapperworker"
}

resource "openstack_networking_secgroup_v2" "sparcworker" {
  name = "sparcworker"
}

resource "openstack_networking_secgroup_v2" "sparcpreviewworker" {
  name = "sparcpreviewworker"
}

// *********** TO CONTROL *****************
resource "openstack_networking_secgroup_rule_v2" "ssh_control_from_cloudflight" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  security_group_id = openstack_networking_secgroup_v2.control.id
  remote_ip_prefix  = "185.225.96.0/22"
}

resource "openstack_networking_secgroup_rule_v2" "icmp_control_from_cloudflight" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.control.id
  remote_ip_prefix  = "185.225.96.0/22"
}

// *********** TO NODE *****************
resource "openstack_networking_secgroup_rule_v2" "all_node_from_control" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.node.id
  remote_group_id   = openstack_networking_secgroup_v2.control.id
}

// *********** TO INFRA *****************
resource "openstack_networking_secgroup_rule_v2" "https_infra_from_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.infra.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "http_infra_from_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.infra.id
  remote_ip_prefix  = "0.0.0.0/0"
}

data "openstack_networking_secgroup_v2" "default" {
  secgroup_id = "07591943-e1dc-4743-9f79-cba7e71c95a8"
  name        = "default"
}

output "control-ip" {
  value = openstack_networking_floatingip_v2.control.address
}

output "infra-ip" {
  value = openstack_networking_floatingip_v2.infra.address
}
