# **Домашнее задание №12:PAM**

## **Задание:**
1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников
* дать конкретному пользователю права работать с докером
и возможность рестартить докер сервис

---

## **Выполнено:**

- Для проверки работы запрета всем пользователям входить в систему
задаем выходные дни в файле  [pam_role/vars/main.yml](pam_role/vars/main.yml).
Например, сегодня пятница, считаем что 5 и 6 дни недели - выходные.
Соответственно назначаем:

```
saturday: 5
sunday: 6
```

- Поднимаем стенд:
```
vagrant up
```

- Проверяем. user1 не входит в группу admin, user2 входит в группу admin. 
Пароль для обоих пользователей и ansible-vault указан в файле passwd
```
[root@s01-deron lab12]# cat passwd
dbu~Lj58vtbtsveYOw1XmL3VaBRQa^tT

[root@s01-deron lab12]# ssh user1@localhost -p 2222
user1@localhost's password:
/usr/local/bin/test_login.sh failed: exit code 1
Authentication failed.
[root@s01-deron lab12]# ssh user2@localhost -p 2222
user2@localhost's password:
[user2@lab12 ~]$
``` 


- Меняем в файле [pam_role/vars/main.yml](pam_role/vars/main.yml)
```
saturday: 6
sunday: 7
```

и проверяем работу настроенной через Polkitd возможность user1 рестартить docker
```
[root@s01-deron lab12]# ansible-playbook playbook.yml
...

[root@s01-deron lab12]# ssh user1@localhost -p 2222
user1@localhost's password:
[user1@lab12 ~]$ systemctl status docker.service
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-27 11:51:02 UTC; 23min ago
     Docs: https://docs.docker.com
 Main PID: 4484 (dockerd)
    Tasks: 8
   Memory: 43.8M
   CGroup: /system.slice/docker.service
           └─4484 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
[user1@lab12 ~]$ systemctl restart docker.service
[user1@lab12 ~]$ systemctl status docker.service
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-27 12:14:48 UTC; 1s ago
     Docs: https://docs.docker.com
 Main PID: 7458 (dockerd)
    Tasks: 8
   Memory: 53.9M
   CGroup: /system.slice/docker.service
           └─7458 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

```

