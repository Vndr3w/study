# План выполнения работы

**Этап 1: Подготовка окружения**

- Установка и настройка необходимого ПО на вашей Ubuntu

<details>
<summary>Ответ</summary>

```bash
# Обновление пакетов
sudo apt update && sudo apt upgrade -y

# Установка Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y

# Установка Ansible
sudo apt install ansible -y

# Установка yandex-cloud CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
# Перезапустите терминал или выполните: source ~/.bashrc

# Установка jq для работы с JSON
sudo apt install jq -y
```

</details>

- Настройка доступа к Yandex Cloud
- Создание структуры проекта

**Этап 2: Создание сети и security groups (Terraform)**

- Создание VPC и подсетей
- Настройка security groups
- Создание bastion host

**Этап 3: Развертывание веб-серверов и балансировщика (Terraform)**

- Создание ВМ для веб-серверов в разных зонах
- Настройка target group, backend group, HTTP router
- Создание Application Load Balancer

**Этап 4: Настройка веб-серверов (Ansible)**

- Установка и настройка nginx
- Размещение статических файлов сайта

**Этап 5: Развертывание мониторинга (Terraform + Ansible)**

- Создание ВМ для Prometheus и Grafana
- Установка и настройка Prometheus, Node Exporter, Nginx Log Exporter
- Установка и настройка Grafana

**Этап 6: Развертывание системы логирования (Terraform + Ansible)**

- Создание ВМ для Elasticsearch и Kibana
- Установка и настройка Elasticsearch, Kibana, Filebeat

**Этап 7: Настройка резервного копирования**

- Настройка snapshot-копий дисков

**Этап 8: Тестирование и проверка**

- Проверка работы сайта
- Проверка мониторинга
- Проверка сбора логов
- Проверка резервного копирования

<details>
<summary>Ответ</summary>



</details>