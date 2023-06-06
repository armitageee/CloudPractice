# Инициализация провайдера OpenStack
provider "openstack" {
  auth_url    = "https://api.selvpc.ru/identity/v3"
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password    = var.password
  region      = var.region
}