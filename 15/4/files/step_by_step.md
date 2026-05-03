### 1. Создаём Dockerfile.python (single stage)

<details>
<summary>Dockerfile.python (single stage)</summary>

```dockerfile
# Используем официальный образ Python 3.12 slim
FROM python:3.12-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем все файлы проекта в контейнер
COPY . .

# Устанавливаем зависимости (если есть requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Открываем порт, который слушает uvicorn
EXPOSE 5000

# Запускаем приложение с помощью uvicorn, делая его доступным по сети
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
```

</details>

### 2. Создаём .dockerignore

<details>
<summary>.dockerignore</summary>

```
.git
__pycache__
*.pyc
.env
venv
*.md
.gitignore
Dockerfile*
.dockerignore
```

</details>

### 3. Создаём docker-compose.yml, для запуска БД и нашего Dockerfile

<details>
<summary>docker-compose.yml</summary>

```yml
services:
  # === БАЗА ДАННЫХ ===
  mysql:
    image: mysql:8
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: example
      MYSQL_USER: app
      MYSQL_PASSWORD: very_strong
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 10s
      retries: 5

  # === PYTHON-ПРИЛОЖЕНИЕ ===
  app:
    build:
      context: .
      dockerfile: Dockerfile.python
    container_name: python-app
    environment:
      DB_HOST: mysql
      DB_USER: app
      DB_PASSWORD: very_strong
      DB_NAME: example
    ports:
      - "5000:5000"
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      backend:
        ipv4_address: 172.20.0.5

  # === REVERSE-PROXY (HAPROXY) ===
  reverse-proxy:
    image: haproxy:2.4
    user: root
    restart: always
    networks:
      - backend
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - ./haproxy/reverse/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:rw

  # === INGRESS-PROXY (NGINX) — host network ===
  ingress-proxy:
    image: nginx:latest
    restart: always
    network_mode: host
    volumes:
      - ./nginx/ingress/default.conf:/etc/nginx/conf.d/default.conf:rw
      - ./nginx/ingress/nginx.conf:/etc/nginx/nginx.conf:rw

volumes:
  mysql-data:

networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24
```

Запускаем и проверям корректность запуска: `docker compose up -d`, после чего проверяем работоспособность `curl http://localhost:5000`/`curl http://localhost:8090`

</details>

### 4. Меняем Dockerfile.python (multistage) на (multi stage)

<details>
<summary>Dockerfile.python (multistage)</summary>

```dockerfile
# ===== Стадия 1 =====
FROM python:3.12-slim AS builder

WORKDIR /build

# Копируем только файл с зависимостями (для кэширования)
COPY requirements.txt .

# Устанавливаем зависимости в отдельную директорию
RUN pip install --no-cache-dir --user -r requirements.txt

# ===== Стадия 2 =====
FROM python:3.12-slim

WORKDIR /app

# Копируем установленные пакеты из builder
COPY --from=builder /root/.local /root/.local

# Копируем весь код приложения
COPY . .

# Добавляем путь к пользовательским пакетам
ENV PATH=/root/.local/bin:$PATH

# Открываем порт, который слушает uvicorn
EXPOSE 5000

# Запускаем приложение с помощью uvicorn, делая его доступным по сети
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
```

Запускаем и проверям корректность запуска: `docker compose up -d`, после чего проверяем работоспособность `curl http://localhost:5000`/`curl http://localhost:8090`

</details>

### 5. Создаём compose.yaml

<details>
<summary>Ответ</summary>

1. Создаём файл compose.yaml

    <details>
    <summary>compose.yaml</summary>

    ```yaml
    name: shvirtd-example

    include:
      - proxy.yaml

    services:
      reverse-proxy:
        user: root
      db:
        image: mysql:8
        container_name: mysql-db
        restart: always
        networks:
          backend:
            ipv4_address: 172.20.0.10
        env_file:
          - .env
        ports:
          - "3306:3306"
        healthcheck:
          test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
          timeout: 10s
          retries: 5

      web:
        build:
          context: .
          dockerfile: Dockerfile.python
        container_name: python-app
        restart: always
        networks:
          backend:
            ipv4_address: 172.20.0.5
        environment:
          DB_HOST: db
          DB_USER: ${MYSQL_USER}
          DB_PASSWORD: ${MYSQL_PASSWORD}
          DB_NAME: ${MYSQL_DATABASE}
        ports:
          - "5000:5000"
        depends_on:
          db:
            condition: service_healthy
    ```

    </details>

2. Запускаем `docker compose -f compose.yaml up -d`
3. Проверяем `curl -L http://127.0.0.1:8090`
4. Подключаемся к MySQL-контейнеру:
     - Загружаем переменные `source .env`
     - Теперь переменная MYSQL_ROOT_PASSWORD доступна `docker exec -it mysql-db mysql -uroot -p"${MYSQL_ROOT_PASSWORD}"`
5. Вводим последовательно команды:
     - `show databases;`
     - `use virtd;`
     - `show tables;`
     - `SELECT * FROM requests LIMIT 10;`

</details>

### 6. Bash-скрипт для клонирования и запуска

<details>
<summary>Ответ</summary>

1. Создаём ВМ и устанавливаем Docker
2. Создаём bash-скрипт для клонирования и запуска

    <details>
    <summary>deploy.sh</summary>

    ```bash
    #!/bin/bash

    REPO_URL="https://github.com/Vndr3w/shvirtd-example-python.git"
    TARGET_DIR="/opt/shvirtd-example-python"

    echo "Удаляем старую директорию, если есть..."
    sudo rm -rf $TARGET_DIR

    echo "Клонируем репозиторий..."
    sudo git clone $REPO_URL $TARGET_DIR

    echo "Переходим в директорию проекта..."
    cd $TARGET_DIR

    echo "Убедимся, что файлы .env и конфиги прокси на месте..."
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
        else
            echo "Создаём .env с минимальными параметрами"
            sudo tee .env > /dev/null <<EOF
    MYSQL_ROOT_PASSWORD=YtReWq4321
    MYSQL_DATABASE=virtd
    MYSQL_USER=app
    MYSQL_PASSWORD=QwErTy1234
    EOF
        fi
    fi

    echo "Запускаем проект через docker compose..."
    docker compose up -d

    echo "Проверяем статус контейнеров..."
    docker ps -a

    echo "Ждём 10 секунд для инициализации..."
    sleep 10

    echo "Проект запущен. Проверьте доступность по адресу: http://$(curl -s ifconfig.me):8090"
    ```

    </details>

3. Даём права на исполнение скрипта `chmod +x deploy.sh`
4. Запускаем скрипт `./deploy.sh`
5. Проверяем работу через [сайт](https://check-host.net/)

</details>

### 7. Запуск remote ssh context

<details>
<summary>Ответ</summary>

```bash
docker context create remote --docker "host=ssh://ubuntu@81.26.190.144"
docker context use remote
docker ps -a
```

</details>

### 8. Повтор SQL-запроса

<details>
<summary>Ответ</summary>

1. Заходим в контейнер mysql `docker exec -it mysql-db mysql -uroot -pYtReWq4321`
2. В mysql:
    ```sql
    SHOW DATABASES;
    USE virtd;
    SHOW TABLES;
    SELECT * FROM requests LIMIT 10;
    ```

</details>

### 9. Анализ слоёв с dive

<details>
<summary>Ответ</summary>

1. Установка dive:
   1. `wget https://github.com/wagoodman/dive/releases/download/v0.12.0/dive_0.12.0_linux_amd64.deb`
   2. `sudo dpkg -i dive_0.12.0_linux_amd64.deb`
2. Анализ образа с dive `dive hashicorp/terraform:latest`
3. Сохранение образа в tar-архив `docker save -o terraform_image.tar hashicorp/terraform:latest`

</details>

### 10. docker cp

<details>
<summary>Ответ</summary>

1. Создать контейнер из образа (не запуская) `docker create --name terraform-cp hashicorp/terraform:latest`
2. Скопировать файл /bin/terraform `docker cp terraform-cp:/bin/terraform ./terraform`
3. Удалить временный контейнер `docker rm terraform-cp`
4. Проверить, что файл работает `chmod +x terraform` `./terraform version`

</details>

### 11. Fix

<details>
<summary>Ответ</summary>

1. Создание контейнера (без запуска) `docker create --name temp-terraform hashicorp/terraform:latest`
2. Сохранение файловой системы контейнера в архив `docker export temp-terraform -o terraform-filesystem.tar`
3. Извлечение бинарного файла из архива:

    ```bash
    # Создаем папку для извлечения
    mkdir extracted-fs

    # Распаковываем tar архив в папку
    tar -xf terraform-filesystem.tar -C extracted-fs

    # Копируем бинарный файл в текущую директорию
    cp extracted-fs/bin/terraform ./terraform

    # Проверяем, что файл скопирован
    ./terraform --version
    ```

</details>