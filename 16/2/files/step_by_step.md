### Задание 1

<details>
<summary>main.tf</summary>

- `platform_id = "standart-v4"` -> `platform_id = "standard-v2"`

- `cores         = 1` -> `cores         = 2`

</details>

<details>
<summary>providers.tf</summary>

- `service_account_key_file = file("~/.authorized_key.json")` -> `service_account_key_file = file("~/.ssh/key.json")`

</details>

<details>
<summary>variables.tf</summary>

- `default     = "<your_ssh_ed25519_key>"` -> `default     = "ssh-rsa AAAAB3NzaC1y..."`

</details>

### Задание 2

<details>
<summary>main.tf</summary>

```hcl
resource "yandex_vpc_network" "develop" {
  name = "vm_web_${ var.vpc_name }"
}

resource "yandex_vpc_subnet" "develop" {
  name           = "vm_web_${ var.vpc_name }"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.vpc_family_image
}

resource "yandex_compute_instance" "platform" {
  name        = "vm_web_${ var.vpc_name_vm }"
  platform_id = var.vpc_platform_id
  resources {
    cores         = var.vpc_cores
    memory        = var.vpc_memory
    core_fraction = var.vpc_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vpc_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vpc_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}
```

</details>

<details>
<summary>variables.tf</summary>

```hcl
###cloud vars

variable "cloud_id" {
  type        = string
  default     = "b1g4hsvetd251u6o7208"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gmq7jclnbgs94c9kq1"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vpc_family_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "vpc_name_vm" {
  type        = string
  default     = "netology-develop-platform-web"
}
variable "vpc_platform_id" {
  type        = string
  default     = "standard-v2"
}

variable "vpc_cores" {
  type        = number
  default     = "2"
}

variable "vpc_memory" {
  type        = number
  default     = "1"
}

variable "vpc_core_fraction" {
  type        = number
  default     = "5"
}

variable "vpc_preemptible" {
  type        = bool
  default     = true
}

variable "vpc_nat" {
  type        = bool
  default     = true
}

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1y..."
  description = "ssh-keygen -t ed25519"
}
```

</details>

### Задание 3

<details>
<summary>main.tf</summary>

```hcl
resource "yandex_vpc_network" "develop" {
  name = "vm_web_${ var.vm_web_net }"
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "vm_web_${ var.vm_web_net }"
  zone           = var.default_zone_web
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_a
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "vm_db_${ var.vm_web_net }"
  zone           = var.default_zone_db
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_b
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family_image
}

resource "yandex_compute_instance" "vm_web" {
  name        = var.vm_web_name
  platform_id = var.vm_web_platform_id
  zone        = var.vm_web_zone
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = var.vm_web_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}

resource "yandex_compute_instance" "vm_db" {
  name        = var.vm_db_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_zone
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = var.vm_db_nat
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}
```

</details>

<details>
<summary>variables.tf</summary>

```hcl
###cloud vars

variable "cloud_id" {
  type        = string
  default     = "cloud_id"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "folder_id"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone_web" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_zone_db" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr_a" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "default_cidr_b" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "vms_ssh_root_key"
  description = "ssh-keygen -t ed25519"
  sensitive   = true
}
```

</details>

<details>
<summary>vms_platform.tf</summary>

```hcl
### 1 vm (vm_web)

variable "vm_web_net" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "vm_web_family_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

variable "vm_web_name" {
  type        = string
  default     = "netology-develop-platform-web"
}
variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v2"
}

variable "vm_web_cores" {
  type        = number
  default     = 2
}

variable "vm_web_memory" {
  type        = number
  default     = 1
}

variable "vm_web_core_fraction" {
  type        = number
  default     = 5
}

variable "vm_web_preemptible" {
  type        = bool
  default     = true
}

variable "vm_web_nat" {
  type        = bool
  default     = true
}

variable "vm_web_zone" {
  type        = string
  default     = "ru-central1-a"
}

### 2 vm (vm_db)

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
}
variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v2"
}

variable "vm_db_cores" {
  type        = number
  default     = 2
}

variable "vm_db_memory" {
  type        = number
  default     = 2
}

variable "vm_db_core_fraction" {
  type        = number
  default     = 20
}

variable "vm_db_preemptible" {
  type        = bool
  default     = true
}

variable "vm_db_nat" {
  type        = bool
  default     = true
}

variable "vm_db_zone" {
  type        = string
  default     = "ru-central1-b"
}
```

</details>

### Задание 4

<details>
<summary>outputs.tf</summary>

```hcl
output "vm_info" {
  description = "Информация о созданных виртуальных машинах"
  value = {
    web = {
      instance_name = yandex_compute_instance.vm_web.name
      external_ip   = yandex_compute_instance.vm_web.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_web.fqdn
    }
    db = {
      instance_name = yandex_compute_instance.vm_db.name
      external_ip   = yandex_compute_instance.vm_db.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_db.fqdn
    }
  }
}
```

</details>

### Задание 5

<details>
<summary>locals.tf</summary>

```hcl
locals {
  vm_web_name = "${ var.project }-${ var.env }-${ var.platform }-web"
  vm_db_name  = "${ var.project }-${ var.env }-${ var.platform }-db"
}
```

</details>

### Задание 6

<details>
<summary>locals.tf</summary>

```hcl
locals {
  vm_web_name     = "${ var.project }-${ var.env }-${ var.platform }-web"
  vm_db_name      = "${ var.project }-${ var.env }-${ var.platform }-db"
  common_metadata = {
    serial-port-enable = "1"
    ssh-keys           = "ubuntu:${ var.vms_ssh_root_key }"
  }
}
```

</details>

<details>
<summary>main.tf</summary>

```hcl
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop_a" {
  name           = "a-zone-${ var.vpc_name }"
  zone           = var.vms_resources["web"].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vms_resources["web"].cidr
}

resource "yandex_vpc_subnet" "develop_b" {
  name           = "b-zone-${ var.vpc_name }"
  zone           = var.vms_resources["db"].zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vms_resources["db"].cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.yandex_compute_image
}

resource "yandex_compute_instance" "vm_web" {
  name        = local.vm_web_name
  platform_id = var.vms_resources["web"].platform_id
  zone        = var.vms_resources["web"].zone
  resources {
    cores         = var.vms_resources["web"].cores
    memory        = var.vms_resources["web"].memory
    core_fraction = var.vms_resources["web"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["web"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_a.id
    nat       = var.vms_resources["web"].nat
  }

  metadata = local.common_metadata
}

resource "yandex_compute_instance" "vm_db" {
  name        = local.vm_db_name
  platform_id = var.vms_resources["db"].platform_id
  zone        = var.vms_resources["db"].zone
  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vms_resources["db"].preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_b.id
    nat       = var.vms_resources["db"].nat
  }

  metadata = local.common_metadata
}
```

</details>

<details>
<summary>outpits.tf</summary>

```hcl
output "vm_info" {
  description = "Информация о созданных виртуальных машинах"
  value = {
    web = {
      instance_name = yandex_compute_instance.vm_web.name
      external_ip   = yandex_compute_instance.vm_web.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_web.fqdn
    }
    db = {
      instance_name = yandex_compute_instance.vm_db.name
      external_ip   = yandex_compute_instance.vm_db.network_interface[0].nat_ip_address
      fqdn          = yandex_compute_instance.vm_db.fqdn
    }
  }
}
```

</details>

<details>
<summary>variables.tf</summary>

```hcl
### cloud vars

variable "cloud_id" {
  type        = string
  default     = "cloud_id"
}

variable "folder_id" {
  type        = string
  default     = "folder_id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

### ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "vms_ssh_root_key"
  description = "ssh-keygen -t ed25519"
  sensitive   = true
}

# Переменные для интерполяции

variable "project" {
  type        = string
  default     = "netology"
}

variable "env" {
  type        = string
  default     = "develop"
}

variable "platform" {
  type        = string
  default     = "platform"
}
```

</details>

<details>
<summary>vms_platform.tf</summary>

```hcl
variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}

variable "yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
}

# Ресурсы для виртуальных машин web и db

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    hdd_size      = number
    hdd_type      = string
    platform_id   = string
    preemptible   = bool
    nat           = bool
    zone          = string
    cidr          = list(string)
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 5
      hdd_size      = 5
      hdd_type      = "network-hdd"
      platform_id   = "standard-v2"
      preemptible   = true
      nat           = false
      zone          = "ru-central1-a"
      cidr          = ["10.0.1.0/24"]
    }
    db = {
      cores         = 2
      memory        = 4
      core_fraction = 20
      hdd_size      = 5
      hdd_type      = "network-hdd"
      platform_id   = "standard-v2"
      preemptible   = true
      nat           = false
      zone          = "ru-central1-b"
      cidr          = ["10.0.2.0/24"]
    }
  }
}

/* Не стал хардкодить ssh, а по другому не получается, вынес в locals.tf
variable "metadata" {
  type = map(string)
  default = {
    serial-port-enable = "1"
    ssh-keys           = "ssh..."
  }
}
*/
```

</details>