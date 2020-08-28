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
vagrant up lab05
vagrant ssh lab05

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
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-1.el7.ngx.src.rpm
```
**- Установим SRC пакет. При установке такого пакета в домашней директории создается древо каталогов для сборки:**
```
rpm -ihv nginx-1.18.0-1.el7.ngx.src.rpm
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
[root@lab05 vagrant]# ll /root/rpmbuild/RPMS/x86_64/
total 3848
-rw-r--r--. 1 root root 2019784 Aug 28 11:14 nginx-1.18.0-1.el7.ngx.x86_64.rpm
-rw-r--r--. 1 root root 1914728 Aug 28 11:14 nginx-debuginfo-1.18.0-1.el7.ngx.x86_64.rpm
```
    
    
### **2.Создать свой репо и разместить там свой RPM**    
**- Устанавливаем nginx из собранного rpm в п.1**
```
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm
```
**- Стартуем nginx и проверяем:**
```
[root@lab05 vagrant]# systemctl start nginx
[root@lab05 vagrant]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-08-28 11:14:38 UTC; 13min ago
     Docs: http://nginx.org/en/docs/
  Process: 18576 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 18577 (nginx)
   CGroup: /system.slice/nginx.service
           ├─18577 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─18585 nginx: worker process

Aug 28 11:14:38 lab05 systemd[1]: Starting nginx - high performance web server...
Aug 28 11:14:38 lab05 systemd[1]: Can't open PID file /var/run/nginx.pid (yet?) after start: No such file or directory
Aug 28 11:14:38 lab05 systemd[1]: Started nginx - high performance web server.

```

**- Создаем свой репозиторий и добавляем созданный пакет:**

```
mkdir /usr/share/nginx/html/repo
сp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
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
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          28-Aug-2020 11:14                   -
<a href="nginx-1.18.0-1.el7.ngx.x86_64.rpm">nginx-1.18.0-1.el7.ngx.x86_64.rpm</a>                  28-Aug-2020 11:14             2019784
</pre><hr></body>
</html>
````
**- Добавляем его в перечень локальных репозиториев:**
```
echo '[lab05repo]' > /etc/yum.repos.d/lab05.repo
echo 'name=Lab05 NGINX Package Repository' >> /etc/yum.repos.d/lab05.repo
echo 'baseurl=http://localhost/repo' >> /etc/yum.repos.d/lab05.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/lab05.repo
echo 'enabled=1' >> /etc/yum.repos.d/lab05.repo
```

**- Проверяем:**
```
[root@lab05 vagrant]# yum repolist enabled | grep lab05
lab05repo                     Lab05 NGINX Package Repository 
[root@lab05 vagrant]# yum list --showduplicates | grep lab05
nginx.x86_64                                1:1.18.0-1.el7.ngx         lab05repo
```

### **3. Реализация пакета через docker**

**- Создаем [Dockerfile](Dockerfile)**


**- Добавляем  в перечень локальных репозиториев репозиторий на машине lab05:**
```
vagrant up lab05docker
vagrant ssh lab05docker

echo '[lab05repo]' > /etc/yum.repos.d/lab05.repo
echo 'name=Lab05 NGINX Package Repository' >> /etc/yum.repos.d/lab05.repo
echo 'baseurl=http://192.168.11.101/repo' >> /etc/yum.repos.d/lab05.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/lab05.repo
echo 'enabled=1' >> /etc/yum.repos.d/lab05.repo
```

**- Скачиваем созданный nginx-1.18.0-1.el7.ngx.x86_64.rpm из репозитория на виртуальной машине lab05**
```
yumdownloader nginx
```


**- Создаем Image**

```
docker build -t deron73/my-nginx-ssl-image:1.1 .
```       

**- Запускаем контейнер и проверяем**
```
docker run -d -p 80:80 deron73/my-nginx-ssl-image:1.1
docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS              PORTS                NAMES
c6c0aa6e5be2        deron73/my-nginx-ssl-image:1.1   "nginx -g 'daemon ..."   About a minute ago   Up About a minute   0.0.0.0:80->80/tcp   stupefied_fermi
ss -tnulp | grep 80
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("docker-proxy-cu",pid=14656,fd=4))

curl localhost
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
docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: deron73
Password:
Login Succeeded
docker push deron73/my-nginx-ssl-image:1.1
The push refers to a repository [docker.io/deron73/my-nginx-ssl-image]
336f4ae91b86: Pushed
94d1f5bc2021: Pushed
613be09ab3c0: Mounted from library/centos
latest: digest: sha256:7da33dfe3e23c32fd6ef6fa50fac00d258d3c5192b0a8a1eff3492b195cb013b size: 952
```

## **Полезное:**

- rpm -qf {file} — показать какому пакету принадлежит {file}

- RPM: верификация:
```
rpm -Vf tree.rpm
rpm -Va
rpm -Vp tree.rpm
rpm -Vv mc
```
- Yum
```
yum search — поиск пакета
yum update — обновление (до версии)
yum downgrade — откат до до версии
yum check-update — проверка обновлений
yum info — информация о пакете
yum provides — найти из какого пакета файл
yum shell — CLI 
```

- Yum history:
```
yum history list
yum history info {N}
yum history undo {N}
```


