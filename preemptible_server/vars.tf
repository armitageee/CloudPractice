variable "keypair_name" {
  default = "tf_keypair"
}

variable "os_auth_url" {
  default = "https://api.selvpc.ru/identity/v3"
}

variable "server_name" {
  default = "tf_server"
}

variable "server_vcpus" {
  default = 1
}

variable "server_ram_mb" {
  default = 1024
}

variable "server_root_disk_gb" {
  default = 5
}

variable "region" {
  default = "ru-7"
}

variable "server_volume_type" {
  default = "basic.ru-7a"
}

variable "server_image_name" {
  default = "Ubuntu 20.04 LTS 64-bit"
}

variable "server_preemptible_tag" {
  default = ["preemptible"]
}

variable "server_no_preemptible_tag" {
  default = []
}

### ATTENTION!!! Do not edit this block, please.
variable "server_zone" {
  type        = string
  description = "The name of the Selectel's pool."

  default = "ru-7a"

  validation {
    condition     = can(regex("ru-7a", var.server_zone))
    error_message = "Preemtible servers are available in ru-7a pool only."
  }
}

# Sensitive block
variable "domain_name" {
  sensitive = true
}

variable "tenant_id" {
  sensitive = true
}

variable "user_name" {
  sensitive = true
}

variable "password" {
  sensitive = true
}