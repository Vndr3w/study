# Код для запуска контейнеров в docker

Создать сеть в docker.

- `docker network create elastic-net`

<details>
<summary>Elasticsearch</summary>

1. Запустить контейнер Elasticsearch
   
    ```bash
    docker run -d \
      --name elasticsearch \
      --network elastic-net \
      -p 9200:9200 \
      -e "cluster.name=netology-test" \
      -e "discovery.type=single-node" \
      -e "xpack.security.enabled=false" \
      elasticsearch:9.2.3
    ```

1. Проверить состояние кластера

    `curl -X GET 'localhost:9200/_cluster/health?pretty'`

</details>

<details>
<summary>Kibana</summary>

1. Запустить контейнер Kibana

    ```bash
    docker run -d \
      --name kibana \
      --network elastic-net \
      -p 5601:5601 \
      -e "ELASTICSEARCH_HOSTS=http://elasticsearch:9200" \
      -e "xpack.security.enabled=false" \
      kibana:9.2.3
    ```

2. Открой браузер и перейди по адресу: http://localhost:5601
3. В левом боковом меню выбрать раздел **Management -> Dev Tools**
4. В открывшейся консоли ввести запрос `GET /_cluster/health?pretty`
5. Нажать кнопку запуска (треугольник) справа от запроса

</details>

<details>
<summary>Logstash</summary>

1. Создать папку для логов на хосте и запустить контейнер, пробросив эту папку внутрь

    ```bash
    mkdir -p /tmp/nginx_logs
    docker run -d \
      --name nginx-server \
      --network elastic-net \
      -p 8080:80 \
      -v /tmp/nginx_logs:/var/log/nginx \
      nginx:latest
    ```
2. Сгенерировать несколько логов `curl localhost:8080`
3. Настроить конфигурацию Logstash

- Создай файл logstash.conf

    ```bash
    input {
      file {
        path => "/var/log/nginx/access.log"
        start_position => "beginning"
      }
    }
    output {
      elasticsearch {
        hosts => ["http://elasticsearch:9200"]
        index => "nginx-logs-%{+YYYY.MM.dd}"
      }
      stdout { codec => rubydebug }
    }
    ```

4. Запустить контейнер Logstash

    ```bash
    docker run -d \
      --name logstash \
      --network elastic-net \
      -v $(pwd)/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro \
      -v /tmp/nginx_logs:/var/log/nginx:ro \
      logstash:9.2.3
    ```

5. Перейди в Kibana по адресу: http://localhost:5601
6. Зайди в Management -> Stack Management -> Data Views и нажать Create data view
7. Ввести имя nginx-logs-* и выберите поле @timestamp. Сохранить.
8. Перейдите в раздел Discover.
9. Выбрать созданный индекс-паттерн nginx-logs-*. Ты увидишь записи логов Nginx.

</details>

<details>
<summary>Filebeat</summary>

1. Остановить или убрать Logstash `docker rm -f logstash`
2. Создать конфиг `filebeat.docker.yml`

    ```bash
    filebeat.inputs:
      - type: filestream
        id: nginx-access
        enabled: true
        paths:
          - /var/log/nginx/access.log

    processors:
      - add_fields:
          target: nginx
          fields:
            via: filebeat

    output.elasticsearch:
      hosts: ["http://elasticsearch:9200"]

    setup.ilm.enabled: false
    ```

3. Запустить контейнер Filebeat

    ```bash
    docker run -d \
      --name filebeat \
      --network elastic-net \
      --user=root \
      -v $(pwd)/filebeat.docker.yml:/usr/share/filebeat/filebeat.yml:ro \
      -v /tmp/nginx_logs:/var/log/nginx:ro \
      docker.elastic.co/beats/filebeat:9.2.3 \
      filebeat -e --strict.perms=false
    ```
4. Сгенерируй пару запросов, чтобы появились новые записи `curl http://localhost:8080/`
5. Проверь, что индексы появились
   - В Kibana -> Dev Tools: `GET _cat/indices/filebeat*?v`
6. Настрой просмотр логов в Kibana
   - В Kibana зайти в Stack Management -> Data views
   - Create data view:
     - Name: filebeat-*
     - Index pattern: filebeat-*
     - Timestamp field: @timestamp.
   - Сохранить
   - Открыть Discover
   - Выбрать data view filebeat-*

</details>