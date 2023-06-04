# Инициализация Terraform и хранения Terraform State
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
  }
  backend "s3" {
    bucket                      = "/students"
    endpoint                    = "s3.storage.selcloud.ru"
    key                         = "tolstoy.tfstate"
    region                      = "ru-1"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}


#-reconfigure -backend-config=path