# **Домашнее задание №10: Инициализация системы. Systemd**

## **Задание:**
Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):
1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig);
2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными 2 файлами.
3. Создать unit-файл(ы) для сервиса:
	- сервис: Kafka, Jira или любой другой
		- у которого код успешного завершения не равен 0
		- (к примеру, приложение Java или скрипт с exit 143)
	- ограничить сервис
		- по использованию памяти
		- ещё по трём ресурсам, которые не были рассмотрены на лекции
	- реализовать один из вариантов restart и объяснить почему выбран именно этот вариант.
	- \* реализовать активацию по .path или .socket

4. \* Скачать демо-версию Atlassian Jira и переписать(!) основной скрипт запуска на unit-файл.

---

## **Выполнено:**

Поднимаем стенд:
```
vagrant up
vagrant ssh
sudo -s
```

1. Создание сервиса, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig

Проверяем работу сервиса:
```
[root@lab10 vagrant]# systemctl status watchlog.timer
● watchlog.timer - Run watchlog script every 30 second
   Loaded: loaded (/etc/systemd/system/watchlog.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Sun 2020-11-22 21:16:59 UTC; 2min 55s ago

Nov 22 21:16:59 lab10 systemd[1]: Started Run watchlog script every 30 second.
[root@lab10 vagrant]# tail -f /var/log/messages
Nov 22 21:19:01 localhost systemd: Started My watchlog service.
Nov 22 21:19:31 localhost systemd: Starting My watchlog service...
Nov 22 21:19:31 localhost root: Sun Nov 22 21:19:31 UTC 2020: I found word, Master!
Nov 22 21:19:31 localhost systemd: Started My watchlog service.
Nov 22 21:19:33 localhost systemd: Created slice User Slice of vagrant.
Nov 22 21:19:33 localhost systemd: Started Session 5 of user vagrant.
Nov 22 21:19:33 localhost systemd-logind: New session 5 of user vagrant.
Nov 22 21:20:01 localhost systemd: Starting My watchlog service...
Nov 22 21:20:01 localhost root: Sun Nov 22 21:20:01 UTC 2020: I found word, Master!
Nov 22 21:20:01 localhost systemd: Started My watchlog service.
```

2. Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами.
Для запуска нескольких экземпляров сервиса будем использовать шаблон httpd@ в конфигурации файла окружений.

Проверяем работу экземпляров сервиса:
```
[root@lab10 vagrant]# systemctl status httpd@first
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2020-11-22 21:17:00 UTC; 9h ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 5686 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─5686 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─5687 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─5688 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─5689 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─5690 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─5691 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─5692 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Nov 22 21:17:00 lab10 systemd[1]: Starting The Apache HTTP Server...
Nov 22 21:17:00 lab10 httpd[5686]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using ... message
Nov 22 21:17:00 lab10 systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.

[root@lab10 vagrant]# systemctl status httpd@second
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2020-11-22 21:17:01 UTC; 9h ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 5802 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─5802 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─5803 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─5804 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─5805 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─5806 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─5808 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─5809 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Nov 22 21:17:01 lab10 systemd[1]: Starting The Apache HTTP Server...
Nov 22 21:17:01 lab10 httpd[5802]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using ... message
Nov 22 21:17:01 lab10 systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.

[root@lab10 vagrant]# sudo ss -tnulp | grep httpd
tcp    LISTEN     0      128    [::]:9000               [::]:*                   users:(("httpd",pid=5809,fd=4),("httpd",pid=5808,fd=4),("httpd",pid=5806,fd=4),("httpd",pid=5805,fd=4),("httpd",pid=5804,fd=4),("httpd",pid=5803,fd=4),("httpd",pid=5802,fd=4))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=5692,fd=4),("httpd",pid=5691,fd=4),("httpd",pid=5690,fd=4),("httpd",pid=5689,fd=4),("httpd",pid=5688,fd=4),("httpd",pid=5687,fd=4),("httpd",pid=5686,fd=4))

[root@lab10 vagrant]# curl http://localhost:9000 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4897  100  4897    0     0   486k      0 --:--:-- --:--:-- --:--:--  531k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<title>Apache HTTP Server Test Page powered by CentOS</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <!-- Bootstrap -->
    <link href="/noindex/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="noindex/css/open-sans.css" type="text/css" />

<style type="text/css"><!--

[root@lab10 vagrant]# curl http://localhost | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4897  100  4897    0     0  94954      0 --:--:-- --:--:-- --:--:--  136k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<title>Apache HTTP Server Test Page powered by CentOS</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <!-- Bootstrap -->
    <link href="/noindex/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="noindex/css/open-sans.css" type="text/css" />

<style type="text/css"><!--

```

3. Создание unit-файл(ы) для сервиса Jira:

Проверяем работу сервиса:
```
[root@lab10 vagrant]# systemctl status jira
● jira.service - Atlassian Jira
   Loaded: loaded (/etc/systemd/system/jira.service; enabled; vendor preset: disabled)
   Active: active (running) since Sun 2020-11-22 21:17:01 UTC; 9h ago
  Process: 5918 ExecStart=/opt/atlassian/jira/bin/start-jira.sh (code=exited, status=0/SUCCESS)
 Main PID: 5951 (java)
   CGroup: /system.slice/jira.service
           └─5951 /opt/atlassian/jira/jre//bin/java -Djava.util.logging.config.file=/opt/atlassian/jira/conf/logging.properties -Djava.u...

Nov 22 21:17:01 lab10 start-jira.sh[5918]: MMMMMM    `UOJ
Nov 22 21:17:01 lab10 start-jira.sh[5918]: MMMMMM
Nov 22 21:17:01 lab10 start-jira.sh[5918]: +MMMMM
Nov 22 21:17:01 lab10 start-jira.sh[5918]: MMMMM
Nov 22 21:17:01 lab10 start-jira.sh[5918]: `UOJ
Nov 22 21:17:01 lab10 start-jira.sh[5918]: Atlassian Jira
Nov 22 21:17:01 lab10 start-jira.sh[5918]: Version : 8.13.1
Nov 22 21:17:01 lab10 start-jira.sh[5918]: If you encounter issues starting or stopping Jira, please see the Troubleshooting guid...llation
Nov 22 21:17:01 lab10 start-jira.sh[5918]: Server startup logs are located in /opt/atlassian/jira/logs/catalina.out
Nov 22 21:17:01 lab10 systemd[1]: Started Atlassian Jira.
Hint: Some lines were ellipsized, use -l to show in full.


[root@lab10 vagrant]# lynx http://localhost:8080

Jira

Jira setup (BUTTON) Language Language

   [setup-mode-instant.png]

Set it up for me

   This is the quick setup for demonstration and evaluation environments. We'll do most of the Jira configuration for you, but you
   need to be online with a working internet connection so we can help you generate a Jira trial license at MyAtlassian. You can
   change the configuration later if you need to.
   [setup-mode-advanced.png]

I'll set it up myself

   Set up and configure your Jira instance manually. This is recommended for production environments, or if you don't have a working
   internet connection.

   Please make sure cookies are enabled before continuing.
   Next



```

Проверяем работу опции Restart=on-failure ( т.к. нам необходимо, чтобы сервис перезапускался при падении):
```
[root@lab10 vagrant]# kill -9 5951

[root@lab10 vagrant]# systemctl status jira
● jira.service - Atlassian Jira
   Loaded: loaded (/etc/systemd/system/jira.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-11-23 07:25:44 UTC; 6s ago
  Process: 2384 ExecStop=/opt/atlassian/jira/bin/stop-jira.sh (code=exited, status=0/SUCCESS)
  Process: 2510 ExecStart=/opt/atlassian/jira/bin/start-jira.sh (code=exited, status=0/SUCCESS)
 Main PID: 2543 (java)
   CGroup: /system.slice/jira.service
           └─2543 /opt/atlassian/jira/jre//bin/java -Djava.util.logging.config.file=/opt/atlassian/jira/conf/logging.properties -Djava.u...

Nov 23 07:25:44 lab10 start-jira.sh[2510]: MMMMMM    `UOJ
Nov 23 07:25:44 lab10 start-jira.sh[2510]: MMMMMM
Nov 23 07:25:44 lab10 start-jira.sh[2510]: +MMMMM
Nov 23 07:25:44 lab10 start-jira.sh[2510]: MMMMM
Nov 23 07:25:44 lab10 start-jira.sh[2510]: `UOJ
Nov 23 07:25:44 lab10 start-jira.sh[2510]: Atlassian Jira
Nov 23 07:25:44 lab10 start-jira.sh[2510]: Version : 8.13.1
Nov 23 07:25:44 lab10 start-jira.sh[2510]: If you encounter issues starting or stopping Jira, please see the Troubleshooting guid...llation
Nov 23 07:25:44 lab10 start-jira.sh[2510]: Server startup logs are located in /opt/atlassian/jira/logs/catalina.out
Nov 23 07:25:44 lab10 systemd[1]: Started Atlassian Jira.
Hint: Some lines were ellipsized, use -l to show in full.
```

Проверяем установку Limit* для сервиса:
```
[root@lab10 vagrant]# cat /proc/2543/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             104857600            209715200            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        0                    unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             657                  657                  processes
Max open files            8192                 8192                 files
Max locked memory         65536                65536                bytes
Max address space         5368709120           6442450944           bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       657                  657                  signals
Max msgqueue size         819200               819200               bytes
Max nice priority         18                   19
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

## **Полезное:**

