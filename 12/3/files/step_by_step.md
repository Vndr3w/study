# Установка и настройка Suricata

- Обновление системы и установка зависимостей: 
  - `sudo apt update && sudo apt upgrade -y`
- Установка Suricata: 
  - `sudo apt install -y software-properties-common`
  - `sudo add-apt-repository ppa:oisf/suricata-stable -y`
  - `sudo apt update`
  - `sudo apt install -y suricata`
- Базовая настройка (Редактирование /etc/suricata/suricata.yaml): 
  - Найди и измени параметр HOME_NET. Обычно это локальная сеть. По умолчанию там уже указаны частные диапазоны (RFC 1918), что подходит для большинства домашних или тестовых лабораторий. Можно оставить значение HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]" или указать конкретную подсеть, например 192.168.1.0/24.
  - Найди секцию af-packet. Это высокопроизводительный метод захвата трафика. В строке interface: укажи имя вашего сетевого интерфейса (узнать его можно командой ip a).
- Запуск и включение в автозагрузку: 
  - `sudo systemctl enable suricata`
  - `sudo systemctl start suricata`
- Обновление правил (Signatures): 
  - `sudo suricata-update`
  - `sudo systemctl restart suricata`
- Проверка работы: 
  - `sudo systemctl status suricata`
  - `sudo tail -f /var/log/suricata/fast.log`

# Установка и настройка Fail2Ban

- Установка Fail2Ban: 
  - `sudo apt install -y fail2ban`
- Настройка защиты SSH: 
  - Основной конфигурационный файл — /etc/fail2ban/jail.conf, но его рекомендуется не трогать, а создать локальный файл jail.local, который имеет приоритет и не перезаписывается при обновлении пакета
    - `sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local`
    - `sudo nano /etc/fail2ban/jail.local`
  - Найди секцию [sshd] и приведи её к следующему виду (или раскомментируй, если она закомментирована):  
      ```bash 
      [sshd]
      enabled = true
      port = ssh
      filter = sshd
      logpath = /var/log/auth.log
      maxretry = 3
      bantime = 3600
      findtime = 600
      ```
    - enabled = true: Включает защиту для SSH.
    - maxretry = 3: Количество неудачных попыток до блокировки.
    - bantime = 3600: Время блокировки IP в секундах (1 час).
    - findtime = 600: Временной промежуток (в секундах), за который считаются неудачные попытки.
- Запуск Fail2Ban: 
  - `sudo systemctl enable fail2ban`
  - `sudo systemctl start fail2ban`
- Проверка работы: 
  - `sudo fail2ban-client status sshd`

# Задание 1

- Установка и настройка SSH:
  ```bash
  # Обновляем пакеты
  sudo apt update

  # Устанавливаем SSH-сервер
  sudo apt install openssh-server -y

  # Проверяем статус SSH
  sudo systemctl status ssh

  # Если SSH не запущен, запускаем
  sudo systemctl start ssh
  sudo systemctl enable ssh

  # Проверяем, что порт 22 слушается
  sudo ss -tlnp | grep :22
  ```
- Установка дополнительных сервисов:
  ```bash
  # Устанавливаем веб-сервер Apache
  sudo apt install apache2 -y

  # Устанавливаем FTP-сервер
  sudo apt install vsftpd -y

  # Запускаем сервисы
  sudo systemctl start apache2
  sudo systemctl enable apache2
  sudo systemctl start vsftpd
  sudo systemctl enable vsftpd

  # Проверяем, что все порты открыты (80, 21, 22)
  sudo ss -tlnp | grep -E ":22|:80|:21"
  ```
- Настройка межсетевого экрана
  ```bash
  # Устанавливаем UFW
  sudo apt install ufw -y

  # Сбрасываем настройки если были
  sudo ufw reset

  # Разрешаем SSH (чтобы не потерять доступ)
  sudo ufw allow ssh
  # ИЛИ конкретный порт
  sudo ufw allow 22/tcp

  # Разрешаем HTTP и FTP
  sudo ufw allow 80/tcp
  sudo ufw allow 21/tcp

  # Включаем фаервол
  sudo ufw --force enable

  # Проверяем статус
  sudo ufw status verbose
  ```
- Очистка логов перед сканированием
  ```bash
  # Очищаем логи Suricata
  sudo systemctl stop suricata
  sudo truncate -s 0 /var/log/suricata/fast.log
  sudo truncate -s 0 /var/log/suricata/eve.json
  sudo systemctl start suricata

  # Очищаем логи Fail2Ban
  sudo systemctl stop fail2ban
  sudo truncate -s 0 /var/log/fail2ban.log
  sudo systemctl start fail2ban

  # Проверяем, что логи чистые
  sudo tail -f /var/log/suricata/fast.log
  # Нажми Ctrl+C чтобы выйти
  ```
- Создание тестовой активности для Fail2Ban `ssh test@192.168.0.0`
- Наблюдение за логами в реальном времени:
  - Терминал 1 - Логи Suricata:
    - `sudo tail -f /var/log/suricata/fast.log`
  - Терминал 2 - Логи Fail2Ban:
    - `sudo tail -f /var/log/fail2ban.log`
    - `watch -n 1 'sudo fail2ban-client status sshd'`
- Порядок выполнения сканирования с Kali
  - TCP SYN сканирование (до открытия портов)
    ```bash 
    sudo nmap -sS 192.168.56.102
    # Покажет закрытые порты
    ```
  - После настройки сервисов
    ```bash
    sudo nmap -sS 192.168.56.102
    # Должен показать открытые порты 21, 22, 80
    ```
  - TCP Connect сканирование
    ```bash
    sudo nmap -sT 192.168.56.102
    ```
  - TCP ACK сканирование
    ```bash
    sudo nmap -sA 192.168.56.102
    ```
  - Определение версий
    ```bash
    sudo nmap -sV 192.168.56.102
    ```
  - Агрессивное сканирование (все вместе)
    ```bash
    sudo nmap -A 192.168.56.102
    ```
- Логи
  - Логи Suricata после всех сканирований:
    ```bash
    cat /var/log/suricata/fast.log | tail -20
    ```
  - Статус Fail2Ban после неудачных попыток:
    ```bash
    sudo fail2ban-client status sshd
    sudo tail -20 /var/log/fail2ban.log
    ```

# Задание 2

- Подготовка файлов со словарями:
  - `mkdir ~/ssh_attack && cd ~/ssh_attack`
  - `nano users.txt`
  
    <details>
    <summary>users.txt</summary>

    ```txt
    root
    user
    test
    ubuntu
    [existing_username]  # Можно добавить реальное имя
    ```

    </details>

  - `nano pass.txt`
  
    <details>
    <summary>pass.txt</summary>

    ```txt
    123456
    password
    qwerty
    [existing_password]  # Правильный пароль для existing_username
    111111
    ```

    </details>

- Запуск атаки Hydra:
  - `hydra -L users.txt -P pass.txt -t 4 <ip-адрес> ssh`

- Включение и настройка защиты SSH с Fail2Ban
- Финальная проверка защиты:
  - `hydra -L users.txt -P pass.txt -t 4 <ip-адрес> ssh`