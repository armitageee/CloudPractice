output "server_outputs" {
  value = [
    "ssh root@${module.preemptible_server.0.floating_ip}",
    "ssh root@${module.preemptible_server.1.floating_ip}",
    "ssh root@${module.preemptible_server.2.floating_ip}"
  ]
}