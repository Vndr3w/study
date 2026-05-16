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
<summary>Ответ</summary>



</details>

###

<details>
<summary>Ответ</summary>



</details>