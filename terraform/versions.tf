terraform {
  required_version = ">= 1.10.5"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
