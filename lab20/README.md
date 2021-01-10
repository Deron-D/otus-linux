# **Домашнее задание №20: Фильтрация трафика - firewalld, iptables**

## **Задание:**
Сценарии iptables
1) реализовать knocking port
- centralRouter может попасть на ssh inetrRouter через knock скрипт
пример в материалах
2) добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост
3) запустить nginx на centralServer
4) пробросить 80й порт на inetRouter2 8080
5) дефолт в инет оставить через inetRouter

* реализовать проход на 80й порт без маскарадинга

---

## **Выполнено:**

![Схема сети](https://github.com/Deron-D/otus-linux/blob/master/lab20/net20.png)


- Поднимаем стенд:
```
vagrant up
```

- Проверяем работу knocking port:
```
[root@s01-deron lab20]# vagrant ssh centralRouter
Last login: Sun Jan 10 17:11:27 2021 from 10.0.2.2

[vagrant@centralRouter ~]$ sudo -s

[root@centralRouter vagrant]# ssh vagrant@192.168.255.1
ssh: connect to host 192.168.255.1 port 22: Connection refused

[root@centralRouter vagrant]# ./knock.sh

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-10 17:12 MSK
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00032s latency).
PORT     STATE    SERVICE
8881/tcp filtered unknown
MAC Address: 08:00:27:A7:7C:A1 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.34 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-10 17:13 MSK
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00034s latency).
PORT     STATE    SERVICE
7777/tcp filtered cbt
MAC Address: 08:00:27:A7:7C:A1 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.33 seconds

Starting Nmap 6.40 ( http://nmap.org ) at 2021-01-10 17:13 MSK
Warning: 192.168.255.1 giving up on port because retransmission cap hit (0).
Nmap scan report for 192.168.255.1
Host is up (0.00034s latency).
PORT     STATE    SERVICE
9991/tcp filtered issa
MAC Address: 08:00:27:A7:7C:A1 (Cadmus Computer Systems)

Nmap done: 1 IP address (1 host up) scanned in 13.35 seconds
Warning: Permanently added '192.168.255.1' (ECDSA) to the list of known hosts.
vagrant@192.168.255.1's password:
Last login: Sun Jan 10 17:11:24 2021 from 10.0.2.2
```

- Проверяем c хостовой машины проброс порта 192.168.10.100:8080->192.168.0.2:80
```
[root@s01-deron lab20]# curl 192.168.10.100:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css">

	html {
```
## **Полезное:**

