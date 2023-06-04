# Terraform
Сначала создаем инфраструктуру на серверах selectel используя terraform и openstack модули <br>
```
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

```
<br>
Структура модулей <br>

![](assets/Снимок%20экрана%202023-06-05%20005011.png)
<br>

```
# Инициализация провайдера OpenStack
provider "openstack" {
  auth_url    = "https://api.selvpc.ru/identity/v3"
  domain_name = var.domain_name
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password    = var.password
  region      = var.region
}
```

Чувствительные данные хранятся в переменной с расширением tfvars <br>
Для конфигурации всего необходимого используем:

```
terraform init #для инициализации с провайдером
terraform plan
terraform apply #для подтверждения всех операций
```

После чего в outpute  терминала отображается количество добавленных ресурсов и данные для ssh подключений
<br>

![](assets/Снимок%20экрана%202023-06-05%20011113.png)

![](assets/Снимок%20экрана%202023-06-05%20012933.png)

![](assets/Снимок%20экрана%202023-06-05%20013141.png)


Для настройки всех инстансов был написан ansible-playbook со следующей структурой ролей:


![](assets/Снимок%20экрана%202023-06-05%20011853.png)

<br>1)Deploy role для доставки всех необходимых файлов на хосты<br>
2)Docker-install для установки docker и docker-compose на всех хостах<br>
3)Conf_files для генерации переменных окружения и добавление в конфигурационные файлы необходимых переменных<br>
4)Docker-infra для поднятия контейнеров на хостах 

Для запуска плейбука потребуется зайти в директорию ansible и ввести команду:

```
ansible-playbook playbook.yml
```
<br>После чего начнется запуск всех задач, для развертки симулятора,базы данных и mqtt брокера<br>

![](assets/Снимок%20экрана%202023-06-05%20014420.png)

После этого мы имеем доступ по публичному ip адресу к grafana 😀<br>

![](assets/Снимок%20экрана%202023-06-05%20014731.png) <br>

Логинимся и открываем вкладку с dashboards: <br>


![](assets/Снимок%20экрана%202023-06-05%20014810.png) <br>

Для удаления всех инстансов используем: <br>
```
terraform destroy
```

