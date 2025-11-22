# Домашнее задание к занятию «Система мониторинга Zabbix» - Лукинов Андрей

## Задание 1 

Установите Zabbix Server с веб-интерфейсом.

### Требования к результатам 
1. Прикрепите в файл README.md скриншот авторизации в админке.

![1.1](img/img1.1.png)
![1.2](img/img1.2.png)

2. Приложите в файл README.md текст использованных команд в GitHub.

	* sudo -s 

	* wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb
	* dpkg -i zabbix-release_latest_6.0+ubuntu24.04_all.deb
	* apt update
	
	* apt install zabbix-server-pgsql zabbix-frontend-php php8.3-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

	* su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'123456789\'';"'
	* su - postgres -c 'psql --command "CREATE DATABASE zabbix OWNER zabbix;"'

	* sed -i 's/# DBPassword=/DBPassword=123456789/g' /etc/zabbix/zabbix_server.conf
	
	* systemctl restart zabbix-server zabbix-agent apache2
	* systemctl enable zabbix-server zabbix-agent apache2 

---

## Задание 2 

Установите Zabbix Agent на два хоста.

### Требования к результатам
1. Приложите в файл README.md скриншот раздела Configuration > Hosts, где видно, что агенты подключены к серверу

![2.1](img/img2.1.png)

2. Приложите в файл README.md скриншот лога zabbix agent, где видно, что он работает с сервером

![2.2](img/img2.2.png)
![2.3](img/img2.3.png)

3. Приложите в файл README.md скриншот раздела Monitoring > Latest data для обоих хостов, где видны поступающие от агентов данные.

![2.4](img/img2.4.png)

4. Приложите в файл README.md текст использованных команд в GitHub

	* sudo -s 
	* wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_6.0+ubuntu24.04_all.deb
	* dpkg -i zabbix-release_latest_6.0+ubuntu24.04_all.deb
	* apt update
	* apt install zabbix-agent
	* systemctl restart zabbix-agent
	* systemctl enable zabbix-agent 
	

	* find / -name zabbix_agentd.conf
	* tail -f /var/log/zabbix/zabbix_agentd.log
	* sed -i 's/Server=127.0.0.1/Server=158.160.208.3/g' /etc/zabbix/zabbix_agentd.conf

---

## Задание 3 со звёздочкой*
Установите Zabbix Agent на Windows (компьютер) и подключите его к серверу Zabbix.

### Требования к результатам
1. Приложите в файл README.md скриншот раздела Latest Data, где видно свободное место на диске C: 

### Критерии оценки

1. Выполнено минимум 2 обязательных задания
2. Прикреплены требуемые скриншоты и тексты 
3. Задание оформлено в шаблоне с решением и опубликовано на GitHub



