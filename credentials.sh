#!/usr/bin/env bash
# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 3 *Identity API* does not necessarily mean any other
# OpenStack API is version 3. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
# unset all currently exported openstack-related environment variables
for var in $(env | sed -n 's/^\(OS.*\)=.*/\1/p'); do unset "$var"; done
export OS_AUTH_URL=https://keystone.cloudferro.com:5000/v3
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
export OS_REGION_NAME="WAW3-2"
export OS_PROJECT_ID="$(cat ./project_id)"
export OS_PROJECT_NAME="cloud_31366_prod"
echo "Please enter your OpenStack username for project $OS_PROJECT_NAME: "
read -r OS_USERNAME_INPUT
export OS_USERNAME=$OS_USERNAME_INPUT
export OS_PROJECT_DOMAIN_ID="6907c34bf7f844abaf8790b1f523f619"
echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
export OS_CLIENT_ID=openstack
export OS_CLIENT_SECRET=16df101f-7a04-4344-9f79-451329ec318a
export OS_PROTOCOL=openid
export OS_IDENTITY_PROVIDER=oidc
export OS_AUTH_TYPE=v3oidcpassword
export OS_DISCOVERY_ENDPOINT="https://identity.cloudferro.com/auth/realms/wekeo-elasticity/.well-known/openid-configuration"

export TF_VAR_USER=$OS_USERNAME
export TF_VAR_TOKEN=$(openstack token issue -f shell -c id | sed 's/id=//g' | sed 's/"//g')
