# **Домашнее задание №16: Сбор и анализ логов**

## **Задание:**
Настраиваем центральный сервер для сбора логов
в вагранте поднимаем 2 машины web и log
на web поднимаем nginx
на log настраиваем центральный лог сервер на любой системе на выбор
- journald
- rsyslog
- elk

настраиваем аудит следящий за изменением конфигов нжинкса

все критичные логи с web должны собираться и локально и удаленно
все логи с nginx должны уходить на удаленный сервер (локально только критичные)
логи аудита должны также уходить на удаленную систему


* развернуть еще машину elk
и таким образом настроить 2 центральных лог системы elk И какую либо еще
в elk должны уходить только логи нжинкса
во вторую систему все остальное
Критерии оценки: 4 - если присылают только логи скриншоты без вагранта
5 - за полную настройку
6 - если выполнено задание со звездочкой

---

## **Выполнено:**

- Поднимаем стенд
```
vagrant up
```

- Проверяем критичные логи с web
```
[root@web vagrant]# logger -p crit Testing critical error
[root@web vagrant]# tail /var/log/messages
Dec 15 21:40:19 localhost vagrant: Testing critical error

[root@log vagrant]# journalctl -D /var/log/journal/remote/ --follow
-- Logs begin at Tue 2020-12-15 21:18:15 UTC. --
Dec 15 21:40:19 web vagrant[4803]: Testing critical error
```

- Проверяем логи nginx
```
[root@web vagrant]# curl localhost

[root@log vagrant]# journalctl -D /var/log/journal/remote/ --follow
Dec 15 22:03:54 web nginx[6719]: web nginx: ::1 - - [15/Dec/2020:22:03:54 +0000] "GET / HTTP/1.1" 200 4833 "-" "curl/7.29.0" "-"

[root@web vagrant]# curl localhost/not_exist

[root@log vagrant]# journalctl -D /var/log/journal/remote/ --follow
Dec 15 22:31:44 web nginx[6894]: web nginx: 2020/12/15 22:31:44 [error] 6894#0: *1 open() "/usr/share/nginx/html/not_exist" failed (2: No such file or directory), client: ::1, server: _, request: "GET /not_exist HTTP/1.1", host: "localhost"
Dec 15 22:31:44 web nginx[6894]: web nginx: ::1 - - [15/Dec/2020:22:31:44 +0000] "GET /not_exist HTTP/1.1" 404 3650 "-" "curl/7.29.0" "-"

[root@web vagrant]# vi /etc/nginx/nginx.conf
[root@web vagrant]# systemctl restart nginx

Broadcast message from systemd-journald@web (Tue 2020-12-15 22:28:03 UTC):

nginx[6872]: 2020/12/15 22:28:03 [emerg] 6872#0: bind() to 0.0.0.0:8888 failed (13: Permission denied)


Message from syslogd@localhost at Dec 15 22:28:03 ...
 nginx:2020/12/15 22:28:03 [emerg] 6872#0: bind() to 0.0.0.0:8888 failed (13: Permission denied)
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@web vagrant]# tail /var/log/nginx/error.log
2020/12/15 22:28:03 [emerg] 6872#0: bind() to 0.0.0.0:8888 failed (13: Permission denied)
```

- Проверяем логи аудита
```
[root@web vagrant]# touch /etc/nginx/nginx.conf.touch
[root@web vagrant]# ausearch -k nginx_config_changed
----
time->Tue Dec 15 22:35:59 2020
type=PROCTITLE msg=audit(1608071759.087:2729): proctitle=746F756368002F6574632F6E67696E782F6E67696E782E636F6E662E746F756368
type=PATH msg=audit(1608071759.087:2729): item=1 name="/etc/nginx/nginx.conf.touch" inode=5078362 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=unconfined_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=PATH msg=audit(1608071759.087:2729): item=0 name="/etc/nginx/" inode=85 dev=08:01 mode=040755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=PARENT cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
type=CWD msg=audit(1608071759.087:2729):  cwd="/home/vagrant"
type=SYSCALL msg=audit(1608071759.087:2729): arch=c000003e syscall=2 success=yes exit=3 a0=7ffea370e7a6 a1=941 a2=1b6 a3=7ffea370dce0 items=2 ppid=4753 pid=27604 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="touch" exe="/usr/bin/touch" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_config_changed"


[root@log vagrant]# ausearch -k nginx_config_changed
time->Tue Dec 15 22:35:59 2020
node=web type=PROCTITLE msg=audit(1608071759.087:2729): proctitle=746F756368002F6574632F6E67696E782F6E67696E782E636F6E662E746F756368
node=web type=PATH msg=audit(1608071759.087:2729): item=1 name="/etc/nginx/nginx.conf.touch" inode=5078362 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=unconfined_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
node=web type=PATH msg=audit(1608071759.087:2729): item=0 name="/etc/nginx/" inode=85 dev=08:01 mode=040755 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:httpd_config_t:s0 objtype=PARENT cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0
node=web type=CWD msg=audit(1608071759.087:2729):  cwd="/home/vagrant"
node=web type=SYSCALL msg=audit(1608071759.087:2729): arch=c000003e syscall=2 success=yes exit=3 a0=7ffea370e7a6 a1=941 a2=1b6 a3=7ffea370dce0 items=2 ppid=4753 pid=27604 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=5 comm="touch" exe="/usr/bin/touch" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_config_changed
```

## **Полезное:**

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-defining_audit_rules_and_controls

https://docs.nginx.com/nginx/admin-guide/monitoring/logging/

https://www.server-world.info/en/note?os=CentOS_7&p=audit&f=2

https://bugzilla.redhat.com/show_bug.cgi?id=973697

```
# journalctl --field=_TRANSPORT - все доступные транспорты
# journalctl _TRANSPORT=syslog - то, что пришло через syslog
# journalctl _TRANSPORT=syslog -o verbose - структурированные данные
# journalctl -p crit
 -p
  emerg (0)
  alert (1) - PRIORITY=1
  crit (2) - PRIORITY=1
  err (3) - PRIORITY=3
  warning (4)
  notice (5)
  info (6)
  debug (7)
# journactl -u mysqld.service -f - отслеживание лога mysql (аналог tail -f)
# journalctl _UID=0 - все с UID 0
# journalctl --list-boots - показать время ребутов сервера (если нет директории то будет показан только последний)
# journalctl -b -2 - показать логи второго бута
```
