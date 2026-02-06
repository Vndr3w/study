#!/bin/bash
PORT=80
WEBROOT=/var/www/html
INDEX_FILE=$WEBROOT/index.html

# Проверка порта (bash /dev/tcp)
if ! timeout 1 bash -c "cat < /dev/null > /dev/tcp/localhost/$PORT" 2>/dev/null; then
    exit 1
fi

# Проверка файла index.html
if [ ! -f "$INDEX_FILE" ]; then
    exit 1
fi

exit 0
