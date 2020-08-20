# **Домашнее задание №5: Управление пакетами. Дистрибьюция софта**

## **Задание:**

Размещаем свой RPM в своем репозитории
1) создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)
2) создать свой репо и разместить там свой RPM
реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо

* реализовать дополнительно пакет через docker
Критерии оценки: 5 - есть репо и рпм
+1 - сделан еще и докер образ

---

## **Выполнено:**

для проверки достаточно использовать [Vagrantfile](Vagrantfile))

### **1.Создать свой RPM пакет (nginx c поддержкой openssl)**

**- Установим необходимые пакеты**
```bash
yum install -y \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc
```

**- Загрузим SRPM пакет NGINX:**
```
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
```
**- Установим SRC пакет. При установке такого пакета в домашней директории создается древо каталогов для сборки:**
```
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
```
**- Скачиваем и разархивируем последний исходник для openssl:**
```
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
```
**- Cтавим все зависимости чтобы в процессе сборки не было ошибок:**
```
yum-builddep rpmbuild/SPECS/nginx.spec
```
**- Правим сам [spec](nginx.spec) файл чтобы NGINX собирался с необходимыми нам опциями:**
```
--with-openssl=/root/openssl-1.1.1g
```
По этой [ссылке](https://nginx.org/ru/docs/configure.html) можно посмотреть все доступные опции для сборки.

**- Собственно, запускаем процесс сборки самого пакета:**
```
rpmbuild -bb rpmbuild/SPECS/nginx.spec
```
**- Проверяем результаты сборки:**
```
[root@s01-deron lab05]# vagrant ssh
[vagrant@lab05 ~]$ sudo -s
[root@lab05 vagrant]# ll ~/rpmbuild/RPMS/x86_64/
total 4388
-rw-r--r--. 1 root root 2001460 Aug 20 13:38 nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2488908 Aug 20 13:38 nginx-debuginfo-1.14.1-1.el7_4.ngx.x86_64.rpm
```
    
    
### **2.Создать свой репо и разместить там свой RPM**    
**- Устанавливаем nginx из собранного rpm в п.1**
```
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
```
**- Стартуем nginx и проверяем:**
```
[root@lab05 vagrant]# systemctl start nginx
[root@lab05 vagrant]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2020-08-20 13:38:40 UTC; 13min ago
     Docs: http://nginx.org/en/docs/
  Process: 18517 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 18518 (nginx)
   CGroup: /system.slice/nginx.service
           ├─18518 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─18528 nginx: worker process

Aug 20 13:38:40 lab05 systemd[1]: Starting nginx - high performance web server...
Aug 20 13:38:40 lab05 systemd[1]: Can't open PID file /var/run/nginx.pid (yet?) after start: No such file or directory
Aug 20 13:38:40 lab05 systemd[1]: Started nginx - high performance web server.
```

**- Создаем свой репозиторий и добавляем два пакета:**

```
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm \
-O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/
```
**- Для прозрачности настроим в NGINX доступ к листингу каталога:**
В location / в файле [/etc/nginx/conf.d/default.conf](default.conf) добавим директиву autoindex on.
В результате location будет выглядеть так:
```
location / {
root /usr/share/nginx/html;
index index.html index.htm;
autoindex on;
}
```
**- Проверяем синтаксис и перезапускаем NGINX:**
```
nginx -t
nginx -s reload
```
**- Проверяем работу репозитория:**
```
[root@lab05 vagrant]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body bgcolor="white">
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          20-Aug-2020 13:38                   -
<a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>                20-Aug-2020 13:38             2001460
<a href="percona-release-0.1-6.noarch.rpm">percona-release-0.1-6.noarch.rpm</a>                   13-Jun-2018 06:34               14520
</pre><hr></body>
</html>
````
**- Добавляем его в перечень локальных репозиториев:**
```
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```

**- Проверяем:**
```
[root@lab05 vagrant]# yum repolist enabled | grep otus
otus                                otus-linux                                 2
[root@lab05 vagrant]# yum list --showduplicates | grep otus
nginx.x86_64                                1:1.14.1-1.el7_4.ngx       otus
percona-release.noarch                      0.1-6                      otus
```

**- Ставим percona-release из локального репозитория:**
```
yum install percona-release -y
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: dedic.sh
 * extras: dedic.sh
 * updates: mirror.docker.ru
Resolving Dependencies
--> Running transaction check
---> Package percona-release.noarch 0:0.1-6 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=====================================================================================================================================================================================================
 Package                                                Arch                                          Version                                      Repository                                   Size
=====================================================================================================================================================================================================
Installing:
 percona-release                                        noarch                                        0.1-6                                        otus                                         14 k

Transaction Summary
=====================================================================================================================================================================================================
Install  1 Package

Total download size: 14 k
Installed size: 16 k
Downloading packages:
No Presto metadata available for otus
percona-release-0.1-6.noarch.rpm                                                                                                                                              |  14 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : percona-release-0.1-6.noarch                                                                                                                                                      1/1
  Verifying  : percona-release-0.1-6.noarch                                                                                                                                                      1/1

Installed:
  percona-release.noarch 0:0.1-6

Complete!
```

### **3. Реализация пакета через docker**

**- Создаем [Dockerfile](Dockerfile)**


**- Скачиваем созданный nginx-1.14.1-1.el7_4.ngx.x86_64.rpm из репозитория виртуальной машины**
```
[root@s01-deron lab05]# wget  http://192.168.11.101/repo/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
--2020-08-20 17:01:47--  http://192.168.11.101/repo/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
Подключение к 192.168.11.101:80... соединение установлено.
HTTP-запрос отправлен. Ожидание ответа... 200 OK
Длина: 2001460 (1,9M) [application/x-redhat-package-manager]
Сохранение в: «nginx-1.14.1-1.el7_4.ngx.x86_64.rpm»

100%[====================================================================================================>] 2 001 460   --.-K/s   за 0,002s

2020-08-20 17:01:47 (875 MB/s) - «nginx-1.14.1-1.el7_4.ngx.x86_64.rpm» сохранён [2001460/2001460]
```


**- Создаем Image**

```
docker build -t deron73/my-nginx-ssl-image:latest .
```       

**- Запускаем контейнер и проверяем**
```
[root@s01-deron lab05]# docker run -d -p 80:80 deron73/my-nginx-ssl-image
2d4247d49cb1e30638aa50827a0a766efaf715015290695cb9d72c547cafa570
[root@s01-deron lab05]# docker ps
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                NAMES
2d4247d49cb1        deron73/my-nginx-ssl-image   "nginx -g 'daemon ..."   29 seconds ago      Up 29 seconds       0.0.0.0:80->80/tcp   hopeful_snyder

[root@s01-deron lab05]#  ss -tnulp | grep 80
udp    UNCONN     0      0         *:47806                 *:*                   users:(("VBoxHeadless",pid=8337,fd=25))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("docker-proxy-cu",pid=9661,fd=4))

[root@s01-deron lab05]# curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

**-  Выкладываем собранный [образ](https://hub.docker.com/repository/docker/deron73/my-nginx-ssl-image) в Docker Hub**
```
[root@s01-deron lab05]# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: deron73
Password:
Login Succeeded
[root@s01-deron lab05]# docker push deron73/my-nginx-ssl-image
The push refers to a repository [docker.io/deron73/my-nginx-ssl-image]
336f4ae91b86: Pushed
94d1f5bc2021: Pushed
613be09ab3c0: Mounted from library/centos
latest: digest: sha256:7da33dfe3e23c32fd6ef6fa50fac00d258d3c5192b0a8a1eff3492b195cb013b size: 952
[root@s01-deron lab05]#
```


## **Полезное:**

