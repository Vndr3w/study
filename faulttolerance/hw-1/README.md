# Домашнее задание к занятию 1 «Disaster recovery и Keepalived» - Лукинов Андрей

## Задание 1
- Дана [схема](1/hsrp_advanced.pkt) для Cisco Packet Tracer, рассматриваемая в лекции.
- На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
- Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
- Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
- На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.

![1](img/img1.png)

[Получившаяся схема](hsrp_lukinovae.pkt)

<details>
<summary> Команды, которые использовал для настройки </summary>

```
Router1
en
conf t
interface GigabitEthernet0/1
standby 1 preempt
standby 1 track GigabitEthernet0/0
ex
ex
wr

Router2
en
conf t
interface GigabitEthernet0/1
standby 1 priority 105
standby 1 track GigabitEthernet0/0
ex
ex
wr
```
</details>

## Задание 2
- Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного [файла](1/keepalived-simple.conf).
- Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
- Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
- Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
- На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html

<details>
<summary> Код, который использовал для установки </summary>

```
sudo apt install nginx keepalived -y
sudo systemctl enable nginx keepalived
sudo systemctl start nginx

vm-1 ->
echo '<h1>VM1 работает!</h1>' | sudo tee /var/www/html/index.html
sudo nano /usr/local/bin/check_web.sh
sudo chmod +x /usr/local/bin/check_web.sh
cd /usr/local/bin/
./check_web.sh 

vm-2 ->
echo '<h1>VM2 работает!</h1>' | sudo tee /var/www/html/index.html
sudo nano /usr/local/bin/check_web.sh
sudo chmod +x /usr/local/bin/check_web.sh
cd /usr/local/bin/
./check_web.sh 

<details>
<summary> check_web.sh </summary>

```
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
```
</details>

sudo nano /etc/keepalived/keepalived.conf

<details>
<summary> keepalived.conf </summary>

```
global_defs {
    router_id LVS_DEVEL
}

vrrp_script check_web {
    script "/usr/local/bin/check_web.sh"
    interval 3
    fall 2
    rise 2
}

vrrp_instance VI_1 {
    interface enp0s8 # Указываем свой интерфейс, ip a
    state MASTER # Сменить на BACKUP
    virtual_router_id 100 # Указываем последний октет виртуальной сети
    priority 200 # Понизить приоритет на BACKUP
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass secret
    }
    virtual_ipaddress {
        192.168.56.100/24 
    }
    track_script {
        check_web
    }
}

```
</details>

sudo systemctl restart keepalived

```
</details>

[Bash-скрипт](check_web.sh)

[Конфигурационный файл keepalived](keepalived.conf)

![vm-1](img/img2.1)

![vm-2](img/img2.2)

![vm-1](img/img2.3)

## Задание 3*
- Изучите дополнительно возможность Keepalived, которая называется vrrp_track_file
- Напишите bash-скрипт, который будет менять приоритет внутри файла в зависимости от нагрузки на виртуальную машину (можно разместить данный скрипт в cron и запускать каждую минуту). Рассчитывать приоритет можно, например, на основании Load average.
- Настройте Keepalived на отслеживание данного файла.
- Нагрузите одну из виртуальных машин, которая находится в состоянии MASTER и имеет активный виртуальный IP и проверьте, чтобы через некоторое время она перешла в состояние SLAVE из-за высокой нагрузки и виртуальный IP переехал на другой, менее нагруженный сервер.
- Попробуйте выполнить настройку keepalived на третьем сервере и скорректировать при необходимости формулу так, чтобы плавающий ip адрес всегда был прикреплен к серверу, имеющему наименьшую нагрузку.
- На проверку отправьте получившийся bash-скрипт и конфигурационный файл keepalived, а также скриншоты логов keepalived с серверов при разных нагрузках
