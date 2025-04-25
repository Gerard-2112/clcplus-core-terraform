resource "openstack_objectstorage_container_v1" "clcpluscore-data" {
  name   = "clcpluscore.data.prod"

  metadata = {
    prod = "true"
  }
}
resource "openstack_identity_ec2_credential_v3" "clcpluscore-data-ec2key1" {}

output "EC2_Data_Credentials" {
  value = "${openstack_identity_ec2_credential_v3.clcpluscore-data-ec2key1.access} // ${openstack_identity_ec2_credential_v3.clcpluscore-data-ec2key1.secret}"
  sensitive = true
}
