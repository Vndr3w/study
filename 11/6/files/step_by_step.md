<details>
<summary>Задание 2</summary>

1. Создать файл [docker-compose.yml](./docker-compose2.yml)

    <details>
    <summary>docker-compose2.yml</summary>

    ```yml
    services:
    mysql-master:
      image: mysql:8.0
      container_name: mysql-master
      command: --server-id=1 --log-bin=mysql-bin --binlog-format=row
      environment:
        MYSQL_ROOT_PASSWORD: rootpass
        MYSQL_DATABASE: testdb
        MYSQL_USER: repl_user
        MYSQL_PASSWORD: replpass
      ports:
        - "3306:3306"
      volumes:
        - master-data:/var/lib/mysql

    mysql-slave:
      image: mysql:8.0
      container_name: mysql-slave
      command: --server-id=2
      environment:
        MYSQL_ROOT_PASSWORD: rootpass
        MYSQL_DATABASE: testdb
      ports:
        - "3307:3306"
      depends_on:
        - mysql-master
      volumes:
        - slave-data:/var/lib/mysql

    volumes:
      master-data:
      slave-data:
    ```

    </details>

2. Запустить 
`docker compose -f docker-compose2.yml up -d`

3. На мастере:
  
  - Подключиться к мастеру через DBeaver как root (host: localhost, port: 3306, user: root, password: rootpass), изменить в Driver properties:
    - allowPublicKeyRetrieval -> true
    - useSSL -> false
  
  - Выполнить следующие команды:
  
  ```sql
  CREATE USER IF NOT EXISTS 'repl_user'@'%' IDENTIFIED BY 'replpass';
  ALTER USER 'repl_user'@'%' IDENTIFIED WITH mysql_native_password BY 'replpasОтветs';
  GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
  FLUSH PRIVILEGES;
  SHOW MASTER STATUS;
  ```

  - Записать File (например, mysql-bin.000003) и Position (например, 1836)

4. На слейве:

  ```sql
  CHANGE REPLICATION SOURCE TO
    SOURCE_HOST='mysql-master',
    SOURCE_PORT=3306,
    SOURCE_USER='repl_user',
    SOURCE_PASSWORD='replpass',
    SOURCE_LOG_FILE='mysql-bin.000003',
    SOURCE_LOG_POS=887;
  START REPLICA;
  SHOW REPLICA STATUS;
  ```

5. На мастере создать таблицу и набить данными

  ```sql
  -- Используем базу testdb
  USE testdb;

  -- Создаем таблицу для теста репликации
  CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );

  -- Заполняем тестовыми данными
  INSERT INTO users (name, email) VALUES 
  ('Иван Иванов', 'ivan@example.com'),
  ('Мария Петрова', 'maria@example.com'),
  ('Петр Сидоров', 'petr@example.com'),
  ('Анна Смирнова', 'anna@example.com'),
  ('Сергей Козлов', 'sergey@example.com');
  ```

6. Проверить, чтобы созданная таблица появилась на слейве
   
</details>

<details>
<summary>Задание 3</summary>

1. Создать файл [docker-compose.yml](./docker-compose3.yml)
   
    <details>
    <summary>docker-compose3.yml</summary>

    ```yml
    services:
      mysql-master-1:
        image: mysql:8.0
        container_name: mysql-master-1
        command: >
          --server-id=1
          --log-bin=mysql-bin
          --binlog-format=ROW
          --default-authentication-plugin=mysql_native_password
        environment:
          MYSQL_ROOT_PASSWORD: toor
          MYSQL_DATABASE: testdb
        ports:
          - "3306:3306"
        volumes:
          - master-1-data:/var/lib/mysql
        networks:
          - mysql-net

      mysql-master-2:
        image: mysql:8.0
        container_name: mysql-master-2
        command: >
          --server-id=2
          --log-bin=mysql-bin
          --binlog-format=ROW
          --default-authentication-plugin=mysql_native_password
        environment:
          MYSQL_ROOT_PASSWORD: toor
          MYSQL_DATABASE: testdb
        ports:
          - "3307:3306"
        volumes:
          - master-2-data:/var/lib/mysql
        networks:
          - mysql-net

    volumes:
      master-1-data:
      master-2-data:
    networks:
      mysql-net:
    ```

    </details>

2. Запустить 
`docker compose -f docker-compose3.yml up -d`

3. На mysql-master-1 (port 3306):
   
  ```sql
  CREATE USER 'repl'@'%' IDENTIFIED BY 'replpass';
  GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
  FLUSH PRIVILEGES;
  FLUSH TABLES WITH READ LOCK;
  SHOW MASTER STATUS;  -- Записать File1:Pos1
  UNLOCK TABLES;
  ```

4. На mysql-master-2 (port 3307):
   
  ```sql
  CREATE USER 'repl'@'%' IDENTIFIED BY 'replpass';
  GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
  FLUSH PRIVILEGES;
  FLUSH TABLES WITH READ LOCK;
  SHOW MASTER STATUS;  -- Записать File2:Pos2
  UNLOCK TABLES;
  ```

5. Cross-replication:
   
  ```sql
  -- master-1 -> master-2
  STOP REPLICA; RESET REPLICA ALL;
  CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-master-2',
  SOURCE_PORT=3306,
  SOURCE_LOG_FILE='File2',
  SOURCE_LOG_POS=Pos2;
  START REPLICA USER='repl' PASSWORD='replpass';

  -- master-2 -> master-1  
  STOP REPLICA; RESET REPLICA ALL;
  CHANGE REPLICATION SOURCE TO
  SOURCE_HOST='mysql-master-1', 
  SOURCE_PORT=3306,
  SOURCE_LOG_FILE='File1',
  SOURCE_LOG_POS=Pos1;
  START REPLICA USER='repl' PASSWORD='replpass';
  ```

</details>
