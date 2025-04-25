# wget 'https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base-9.5-20241118.0.x86_64.qcow2'
# openstack image create --disk-format qcow2 --file Rocky-9-GenericCloud-Base-9.5-20241118.0.x86_64.qcow2 --min-disk 5 --min-ram 512 --property hw_disk_bus='scsi' --property hw_scsi_model='virtio-scsi' Rocky-9-GenericCloud-Base-9.5
data "openstack_images_image_v2" "default" {
  name        = "Rocky-9-GenericCloud-Base-9.5"
  most_recent = true
}
