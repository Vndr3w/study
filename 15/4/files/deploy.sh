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
