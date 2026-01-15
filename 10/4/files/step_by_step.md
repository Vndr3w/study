<details>
<summary>Задание 1</summary>

- Установка RabbitMQ
1. `sudo apt update`
2. `sudo apt install -y rabbitmq-server`
3. `sudo systemctl enable rabbitmq-server`
4. `sudo systemctl start rabbitmq-server`

- Включение management plug-in
1. `sudo rabbitmq-plugins enable rabbitmq_management`

- Вход в веб-интерфейс
1. http://localhost:15672
2. login: guest / password: guest

</details>

<details>
<summary>Задание 2</summary>

- Подготовка Python и Pika
1. `sudo apt update`
2. `sudo apt install -y python3-venv python3-full`

- Создай venv рядом со скриптами и активируй
1. `python3 -m venv .venv`
2. `source .venv/bin/activate`

- Установи Pika внутри venv и запусти скрипты
1. `pip install pika`
2. `python producer.py`

    <details>
    <summary>Код</summary>
    
    ```py
    #!/usr/bin/env python
    # coding=utf-8
    import pika

    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue='hello')
    channel.basic_publish(exchange='', routing_key='hello', body='Hello Netology!')
    connection.close()
    ```
    
    </details>

3. `python consumer.py`

    <details>
    <summary>Код</summary>

    ```py
    #!/usr/bin/env python
    # coding=utf-8
    import pika

    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    channel = connection.channel()
    channel.queue_declare(queue='hello')


    def callback(ch, method, properties, body):
        print(" [x] Received %r" % body)


    channel.basic_consume(queue='hello', on_message_callback=callback, auto_ack=True)
    channel.start_consuming()
    ```

    </details>

4. Выйти из venv `deactivate`

</details>

<details>
<summary>Задание 3</summary>

- Узнать имя ноды 
1. `sudo rabbitmqctl status | grep -i "Node name"`

- Прописать имена в /etc/hosts на ОБЕИХ ВМ
1. `sudo nano /etc/hosts`
   - ip-address node name (В примере ip-address: 192.168.56.5, node name: rmq01)
   - ip-address node name (В примере ip-address: 192.168.56.6, node name: rmq02)

- Синхронизируй Erlang cookie (обязательно)
1. На rmq01:
   - `sudo cat /var/lib/rabbitmq/.erlang.cookie`
2. На rmq02:
   - Останови RabbitMQ `sudo systemctl stop rabbitmq-server`
   - Вставь cookie (значение ровно как на rmq01) `sudo nano /var/lib/rabbitmq/.erlang.cookie`
   - Выставь права и владельца:
     - `sudo chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie`
     - `sudo chmod 400 /var/lib/rabbitmq/.erlang.cookie`
   - Запусти RabbitMQ `sudo systemctl start rabbitmq-server`
   - Собери кластер:
     - sudo rabbitmqctl stop_app
     - sudo rabbitmqctl reset
     - sudo rabbitmqctl join_cluster node name (Из примера: rabbit@rmq01)
     - sudo rabbitmqctl start_app
   - Проверь cluster_status `sudo rabbitmqctl cluster_status`
   - Включи политику ha-all (mirrored queues на все очереди)
     - На любой ноде выполнить `sudo rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}'`

- Проверка сообщением: producer -> rabbitmqadmin get на каждой ноде
1. Запусти producer.py через venv
2. На обеих нодах выполни команду `rabbitmqadmin get queue='hello'`

- Тест отказа ноды
1. Выключи rmq01 (Остановить ВМ)
2. На rmq02 и запусти consumer.py