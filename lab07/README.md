# **Домашнее задание №7: Bash**

## **Задание:**
Пишем скрипт
написать скрипт для крона
который раз в час присылает на заданную почту
- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
- все ошибки c момента последнего запуска
- список всех кодов возврата с указанием их кол-ва с момента последнего запуска
в письме должно быть прописан обрабатываемый временной диапазон
должна быть реализована защита от мультизапуска
Критерии оценки:
трапы и функции, а также sed и find +1 балл

---

## **Выполнено:**

- Для проверки достаточно использовать [Vagrantfile](Vagrantfile)

- Результат вывода сообщения из /var/spool/mail/vagrant:

```
[root@lab07 vagrant]# cat /var/spool/mail/vagrant
From root@lab07.localdomain  Wed Oct 21 16:11:24 2020
Return-Path: <root@lab07.localdomain>
X-Original-To: vagrant@localhost.localdomain
Delivered-To: vagrant@localhost.localdomain
Received: by localhost.localdomain (Postfix, from userid 0)
        id 15C124081852; Wed, 21 Oct 2020 16:11:24 +0000 (UTC)
Date: Wed, 21 Oct 2020 16:11:24 +0000
To: vagrant@localhost.localdomain
Subject: HTTPD usage report from 14/Aug/2019:04:12:10 to
 15/Aug/2019:00:25:46
User-Agent: Heirloom mailx 12.5 7/5/10
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20201021161124.15C124081852@lab07.localdomain>
From: root@lab07.localdomain (root)

=============================================
HTTPD usage report
Analyze period is from 14/Aug/2019:04:12:10 to 15/Aug/2019:00:25:46
=============================================
10 top IP addresses
45 93.158.167.130
39 109.236.252.130
37 212.57.117.19
33 188.43.241.106
31 87.250.233.68
24 62.75.198.172
22 148.251.223.21
20 185.6.8.9
17 217.118.66.161
16 95.165.18.146
---------------------------------------------
10 top requested addresses
157 /
120 /wp-login.php
57 /xmlrpc.php
26 /robots.txt
12 /favicon.ico
9 /wp-includes/js/wp-embed.min.js?ver=5.0.4
7 /wp-admin/admin-post.php?page=301bulkoptions
7 /1
6 /wp-content/uploads/2016/10/robo5.jpg
6 /wp-content/uploads/2016/10/robo4.jpg
---------------------------------------------
All errors since the last launch
51 404
7 400
3 500
2 499
1 405
1 403
---------------------------------------------
A list of all return codes indicating their number since the last launch
498 200
95 301
51 404
18 400
3 500
2 499
1 405
1 403
1 304
---------------------------------------------
```

## **Полезное:**

[The GNU Awk User’s Guide](https://www.gnu.org/software/gawk/manual/html_node/Splitting-By-Content.html#Splitting-By-Content)
