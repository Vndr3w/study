<details>
<summary>Задание 1</summary>

1. Запуск MySQL 8.0 через Docker

  ```bash
  docker run --name hw-mysql \
    -e MYSQL_ROOT_PASSWORD=rootpassword \
    -p 3306:3306 \
    -v hw-mysql-data:/var/lib/mysql \
    -d mysql:8.0

  docker exec -it hw-mysql mysql -uroot -p
  ```

2. Создание учётной записи sys_temp
  
  ```sql
  CREATE USER 'sys_temp'@'localhost' IDENTIFIED BY 'password123';
  ```

3. Получение списка пользователей

  ```sql
  SELECT user, host FROM mysql.user;
  ```

4. Предоставление всех прав пользователю sys_temp

  ```sql
  GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
  ```

5. Получение списка прав для sys_temp

  ```sql
  SHOW GRANTS FOR 'sys_temp'@'localhost';
  ```

6. Изменение типа аутентификации и переподключение

- Смена типа аутентификации:
  
  ```sql
  ALTER USER 'sys_temp'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password123';
  FLUSH PRIVILEGES;
  ```
- Выход и переподключение:
  
  `exit`
  `docker exec -it hw-mysql mysql -u sys_temp -p`

7. Скачивание и восстановление дамп базы Sakila

- Создание базы данных:
  
  ```sql
  CREATE DATABASE sakila;
  exit
  ```

- Скачивание:
  `wget https://downloads.mysql.com/docs/sakila-db.zip`
  `unzip sakila-db.zip`

- Восстановление дампа:
  `docker cp sakila-db hw-mysql:/tmp/`
  `docker exec -it hw-mysql ls -la /tmp/sakila-db/`
  `docker exec -it hw-mysql bash`
  `mysql -u sys_temp -ppassword123 sakila < /tmp/sakila-db/sakila-schema.sql`
  `mysql -u sys_temp -ppassword123 sakila < /tmp/sakila-db/sakila-data.sql`
  `exit`

8. Получение всех таблиц базы данных

  ```sql
  -- Переключаемся на базу sakila
  USE sakila;

  -- Смотрим все таблицы
  SHOW TABLES;

  -- Смотрим полную информацию о таблицах
  SHOW FULL TABLES;

  -- Проверяем количество данных в таблицах
  SELECT COUNT(*) FROM actor;
  SELECT COUNT(*) FROM film;
  SELECT COUNT(*) FROM customer;

  -- Смотрим структуру таблицы actor
  DESCRIBE actor;

  -- Тестовый запрос данных
  SELECT * FROM actor LIMIT 5;
  ```

</details>

<details>
<summary>Задание 2</summary>

1. Подключится в DBeaver к MySQL
2. Открыть SQL скрипт

  ```sql
  USE sakila;

  SELECT 
      TABLE_NAME AS 'Название таблицы',
      COLUMN_NAME AS 'Название первичного ключа'
  FROM 
      INFORMATION_SCHEMA.COLUMNS
  WHERE 
      TABLE_SCHEMA = 'sakila' 
      AND COLUMN_KEY = 'PRI'
  ORDER BY 
      TABLE_NAME;
  ```

</details>

<details>
<summary>Задание 3</summary>

1. Подключение к MySQL (root)

```bash
docker exec -it hw-mysql mysql -u root -prootpassword
```

2. Отзыв прав на внесение, изменение и удаление данных

```sql
-- 1. Отзываем ГЛОБАЛЬНЫЙ грант
REVOKE ALL PRIVILEGES ON *.* FROM 'sys_temp'@'localhost';
FLUSH PRIVILEGES;

-- 2. Даем только SELECT на sakila
GRANT SELECT ON sakila.* TO 'sys_temp'@'localhost';
FLUSH PRIVILEGES;
```
</details>