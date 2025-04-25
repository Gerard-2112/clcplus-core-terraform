variable "USER" {
    type = string
}

variable "TOKEN" {
    type = string
}

provider "openstack" {
    user_name = var.USER
    tenant_name = "cloud_31366_1"
    auth_url = "https://keystone.cloudferro.com:5000/v3"
    domain_name = "cloud_31366_1"
    token = var.TOKEN
}
