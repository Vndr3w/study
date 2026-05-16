# Домашнее задание к занятию «Введение в Terraform» - Лукинов Андрей

## Задание 1

<details>
<summary>Ответ</summary>

1. Перейдите в каталог [**src**](https://github.com/netology-code/ter-homeworks/tree/main/01/src). Скачайте все необходимые зависимости, использованные в проекте.
   
    ![1.1](./img/img1.1.png)

    ![1.2](./img/img1.2.png)

2. Изучите файл **.gitignore**. В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию?(логины,пароли,ключи,токены итд)
    - Личную секретную информацию (логины, пароли, ключи, токены) допустимо сохранять в файле `personal.auto.tfvars`, поскольку он явно исключён из .gitignore и не будет передан в репозиторий.

3. Выполните код проекта. Найдите  в state-файле секретное содержимое созданного ресурса **random_password**, пришлите в качестве ответа конкретный ключ и его значение.

    ![3.1](./img/img3.1.png)
    
    - Значение ключа "result": "1ZtKFbUZp2Q2xkPm"

4. Раскомментируйте блок кода, примерно расположенный на строчках 29–42 файла **main.tf**. Выполните команду ```terraform validate```. Объясните, в чём заключаются намеренно допущенные ошибки. Исправьте их.
    
    ![4.1](./img/img4.1.png)

    - Имя контейнера начинается с цифры – 1nginx -> нарушает правила именования ресурсов Terraform.
    - Обращение к несуществующему ресурсу: random_password.random_string_FAKE.resulT -> правильное имя ресурса – random_password.random_string, а атрибут – result (без заглавной буквы).
    - Отсутствует блок required_providers для random (провайдер random).

5. Выполните код. В качестве ответа приложите: исправленный фрагмент кода и вывод команды ```docker ps```.

    ![5.1](./img/img5.1.png)

    ![5.2](./img/img5.2.png)

    <details>
    <summary>Исправленный код</summary>

    ```
    terraform {
      required_providers {
        docker = {
          source = "kreuzwerker/docker"
        }
        random = {
          source = "hashicorp/random"
        }
      }
    }

    resource "random_password" "random_string" {
      length  = 16
      special = false
      min_upper = 1
      min_lower = 1
      min_numeric = 1
    }

    resource "docker_image" "nginx" {
      name         = "nginx:latest"
      keep_locally = true
    }

    resource "docker_container" "nginx_container" {
      image = docker_image.nginx.image_id
      name  = "example_${random_password.random_string.result}"
      ports {
        internal = 80
        external = 9090
      }
    }
    ```
    
    </details>

    ![5.3](./img/img5.3.png)

6. Замените имя docker-контейнера в блоке кода на ```hello_world```. Не перепутайте имя контейнера и имя образа. Мы всё ещё продолжаем использовать name = "nginx:latest". Выполните команду ```terraform apply -auto-approve```. Объясните своими словами, в чём может быть опасность применения ключа  ```-auto-approve```. Догадайтесь или нагуглите зачем может пригодиться данный ключ? В качестве ответа дополнительно приложите вывод команды ```docker ps```.
    
    ![6.1](./img/img6.1.png)

    - Ключ `-auto-approve` автоматически подтверждает применение изменений без интерактивного запроса. Это может привести к:
      - Случайному изменению/удалению production-ресурсов.
      - Неконтролируемому созданию ресурсов с непредвиденными последствиями.
      - Выполнению невалидной конфигурации (ошибки не будут проверены пользователем).
    - Когда полезен:
      - В CI/CD пайплайнах для автоматизации развёртывания.
      - При разработке и тестировании в изолированных окружениях.
      - При заведомо безопасных операциях.
7. Уничтожьте созданные ресурсы с помощью **terraform**. Убедитесь, что все ресурсы удалены. Приложите содержимое файла **terraform.tfstate**.
   
   ![7.1](./img/img7.1.png)

   ![7.2](./img/img7.2.png)

8. Объясните, почему при этом не был удалён docker-образ **nginx:latest**. Ответ **ОБЯЗАТЕЛЬНО НАЙДИТЕ В ПРЕДОСТАВЛЕННОМ КОДЕ**, а затем **ОБЯЗАТЕЛЬНО ПОДКРЕПИТЕ** строчкой из документации [**terraform провайдера docker**](https://library.tf/providers/kreuzwerker/docker/latest).  (ищите в классификаторе resource docker_image)

    ![8.1](./img/img8.1.png)

    ![8.2](./img/img8.2.png)

    - ```keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation.```

</details>

## Задание 2*

1. Создайте в облаке ВМ. Сделайте это через web-консоль, чтобы не слить по незнанию токен от облака в github(это тема следующей лекции). Если хотите - попробуйте сделать это через terraform, прочитав документацию yandex cloud. Используйте файл ```personal.auto.tfvars``` и гитигнор или иной, безопасный способ передачи токена!
2. Подключитесь к ВМ по ssh и установите стек docker.
3. Найдите в документации docker provider способ настроить подключение terraform на вашей рабочей станции к remote docker context вашей ВМ через ssh.
4. Используя terraform и  remote docker context, скачайте и запустите на вашей ВМ контейнер ```mysql:8``` на порту ```127.0.0.1:3306```, передайте ENV-переменные. Сгенерируйте разные пароли через random_password и передайте их в контейнер, используя интерполяцию из примера с nginx.(```name  = "example_${random_password.random_string.result}"```  , двойные кавычки и фигурные скобки обязательны!) 

```
    environment:
      - "MYSQL_ROOT_PASSWORD=${...}"
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - "MYSQL_PASSWORD=${...}"
      - MYSQL_ROOT_HOST="%"
```

5. Зайдите на вашу ВМ , подключитесь к контейнеру и проверьте наличие секретных env-переменных с помощью команды ```env```. Запишите ваш финальный код в репозиторий.

## Задание 3*

1. Установите [opentofu](https://opentofu.org/)(fork terraform с лицензией Mozilla Public License, version 2.0) любой версии
2. Попробуйте выполнить тот же код с помощью ```tofu apply```, а не terraform apply.