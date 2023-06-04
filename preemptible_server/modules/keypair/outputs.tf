output "keypair_id" {
  value = openstack_compute_keypair_v2.key_tf.id
}

output "keypair_name" {
  value = openstack_compute_keypair_v2.key_tf.name
}
