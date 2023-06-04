# Создание ключевой пары для доступа к ВМ
module "keypair" {
  source             = "./modules/keypair"
  keypair_name       = "keypair-tf"
  keypair_public_key = file("~/.ssh/id_rsa.pub")
  region             = var.region
}

# Создание приватной сети для ВМ
module "nat" {
  source = "./modules/nat"
}

# Создание прерываемого сервера.
module "preemptible_server" {
  count  = 3
  source = "./modules/server_remote_root_disk"

  server_name         = var.server_name
  server_zone         = var.server_zone
  server_vcpus        = var.server_vcpus
  server_ram_mb       = var.server_ram_mb
  server_root_disk_gb = var.server_root_disk_gb
  server_volume_type  = var.server_volume_type
  server_image_name   = var.server_image_name
  server_ssh_key      = module.keypair.keypair_name
  region              = var.region
  network_id          = module.nat.network_id
  subnet_id           = module.nat.subnet_id

  # Для смены прерываемого сервера на обычный используйте
  # переменную server_no_preemptible_tag:
  # server_preemptible_tag = var.server_no_preemptible_tag
  server_preemptible_tag = var.server_preemptible_tag
  #  server_ssh_key_user    = ""
}

# Создание inventory файла для ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("./resources/inventory.tmpl",
    {
      simulator_vm_ip_public = module.preemptible_server.0.floating_ip,
      simulator_vm_ip_nat    = module.preemptible_server.0.nat_ip.0,
      broker_vm_ip_public    = module.preemptible_server.1.floating_ip,
      broker_vm_ip_nat       = module.preemptible_server.1.nat_ip.0,
      database_vm_ip_public  = module.preemptible_server.2.floating_ip,
      database_vm_ip_nat     = module.preemptible_server.2.nat_ip.0
    }
  )
  filename = "../ansible/inventory.ini"
}
