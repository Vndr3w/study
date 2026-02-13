# Домашнее задание к занятию  «Защита хоста» - Лукинов Андрей

## Задание 1

1. Установите **eCryptfs**.
2. Добавьте пользователя cryptouser.
3. Зашифруйте домашний каталог пользователя с помощью eCryptfs.

    <details>
    <summary>Скриншоты</summary>

    *В качестве ответа  пришлите снимки экрана домашнего каталога пользователя с исходными и зашифрованными данными.*

    ![1.1](./img/img1.1.png) **Установка eCryptfs**

    ![1.2](./img/img1.2.png) **Создание пользователя cryptouser**

    ![1.3](./img/img1.3.png) **Настройка шифрования домашней директории**

    ![1.4](./img/img1.4.png) **Монтирование зашифрованной домашней директории**

    ![1.5](./img/img1.5.png) **Проверка и создание тестовых файлов**

    ![1.6](./img/img1.6.png) **Демонстрация шифрования**

    ![1.7](./img/img1.7.png) **Демонстрация шифрования**

    </details>

## Задание 2

1. Установите поддержку **LUKS**.
2. Создайте небольшой раздел, например, 100 Мб.
3. Зашифруйте созданный раздел с помощью LUKS.

    <details>
    <summary>Скриншоты</summary>

    *В качестве ответа пришлите снимки экрана с поэтапным выполнением задания.*

    ![2.1](./img/img2.1.png) **Установка поддержки LUKS**

    ![2.2](./img/img2.2.png) **Создание файла-контейнера (dd команда и ls -lh), привязка к loop-устройству (losetup команда), инициализация LUKS (cryptsetup luksFormat), открытие контейнера (cryptsetup luksOpen)**

    ![2.3](./img/img2.3.png) **Создание ФС и монтирование (mkfs.ext4, mount, df -h), информация LUKS (cryptsetup luksDump)**

    ![2.4](./img/img2.4.png) **Работа с зашифрованным разделом, корректное завершение работы**

    </details>

    <details>
    <summary>Использованный код</summary>

    ```bash
    # 1. Создание файла
    dd if=/dev/zero of=~/luks-container.img bs=1M count=100

    # 2. Настройка loop
    sudo losetup -fP ~/luks-container.img
    sudo losetup -l

    # 3. LUKS форматирование
    sudo cryptsetup luksFormat /dev/loop0

    # 4. Открытие
    sudo cryptsetup luksOpen /dev/loop0 my_encrypted

    # 5. Файловая система
    sudo mkfs.ext4 /dev/mapper/my_encrypted

    # 6. Монтирование
    sudo mkdir -p /mnt/encrypted
    sudo mount /dev/mapper/my_encrypted /mnt/encrypted
    df -h

    # 7. Информация
    sudo cryptsetup luksDump /dev/loop0
    ```
    
    </details>

## Задание 3*

1. Установите **apparmor**.
2. Повторите эксперимент, указанный в лекции.
3. Отключите (удалите) apparmor.

    <details>
    <summary>Ответ</summary>

    *В качестве ответа пришлите снимки экрана с поэтапным выполнением задания.*

    ![3.1](./img/img3.1.png) **Установка AppArmor**

    ![3.2](./img/img3.2.png) **Проверка установки AppArmor**

    ![3.3](./img/img3.3.png) **Профили**

    ![3.4](./img/img3.4.png) **Проверка работы профилей**

    </details>

    <details>
    <summary>Использованный код</summary>

    ```bash
    sudo apt update
    sudo apt install apparmor apparmor-profiles apparmor-profiles-extra apparmor-utils apparmor-notify -y
    sudo systemctl restart apparmor
    sudo systemctl status apparmor

    ls /etc/apparmor.d
    sudo cp /usr/bin/man /usr/bin/man1
    sudo cp /bin/ping /usr/bin/man
    sudo man 127.0.0.1 # Будет блокироваться apparmor из-за профилей
    sudo systemctl stop apparmor
    sudo aa-teardown  
    sudo man 127.0.0.1 # Заработает как пинг
    ```

    </details>