# **Домашнее задание №27: PostgreSQL**

## **Задание:**
репликация postgres
- Настроить hot_standby репликацию с использованием слотов
- Настроить правильное резервное копирование

Для сдачи работы присылаем ссылку на репозиторий, в котором должны обязательно быть
- Vagranfile (2 машины)
- плейбук Ansible
- конфигурационные файлы postgresql.conf, pg_hba.conf и recovery.conf,
- конфиг barman, либо скрипт резервного копирования.

Команда "vagrant up" должна поднимать машины с настроенной репликацией и резервным копированием.
Рекомендуется в README.md файл вложить результаты (текст или скриншоты) проверки работы репликации и резервного копирования.

пример плейбука:
```
---
- name: Установка postgres11
hosts: master, slave
become: yes
roles:
- postgres_install

- name: Настройка master
hosts: master
become: yes
roles:
- master-setup

- name: Настройка slave
hosts: slave
become: yes
roles:
- slave-setup

- name: Создание тестовой БД
hosts: master
become: yes
roles:
- create_test_db

- name: Настройка barman
hosts: barman
become: yes
roles:
- barman_install
tags:
- barman
```

---

## **Выполнено:**

- Поднимаем стенд:
```
git clone https://github.com/Deron-D/otus-linux && cd otus-linux/lab27 && vagrant up
```

- Проверяем созданные слоты:
```
[root@s01-deron lab27]# vagrant ssh master
Last login: Sat Jan 16 14:16:41 2021 from 10.0.2.2
[vagrant@master ~]$ sudo -s
[root@master vagrant]# su postgres
bash-4.2$ psql
could not change directory to "/home/vagrant": Permission denied
psql (11.10)
Type "help" for help.

postgres=# \x
Expanded display is on.
postgres=# select * from pg_replication_slots;
-[ RECORD 1 ]-------+-------------
slot_name           | standby_slot
plugin              |
slot_type           | physical
datoid              |
database            |
temporary           | f
active              | t
active_pid          | 4567
xmin                |
catalog_xmin        |
restart_lsn         | 0/12013F78
confirmed_flush_lsn |
-[ RECORD 2 ]-------+-------------
slot_name           | barman
plugin              |
slot_type           | physical
datoid              |
database            |
temporary           | f
active              | t
active_pid          | 4944
xmin                |
catalog_xmin        |
restart_lsn         | 0/12000000
confirmed_flush_lsn |

postgres=#
```

- Проверяем статус репликации:
```
postgres=# select * from pg_stat_replication;
-[ RECORD 1 ]----+------------------------------
pid              | 4567
usesysid         | 16384
usename          | replica
application_name | walreceiver
client_addr      | 192.168.11.151
client_hostname  |
client_port      | 36310
backend_start    | 2021-01-16 11:16:37.753801+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/12013F78
write_lsn        | 0/12013F78
flush_lsn        | 0/12013F78
replay_lsn       | 0/12013F78
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
-[ RECORD 2 ]----+------------------------------
pid              | 4944
usesysid         | 16386
usename          | streaming_barman
application_name | barman_receive_wal
client_addr      | 192.168.11.152
client_hostname  |
client_port      | 54972
backend_start    | 2021-01-16 11:18:01.447276+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/12013F78
write_lsn        | 0/12013F78
flush_lsn        | 0/12000000
replay_lsn       |
write_lag        | 00:00:09.741218
flush_lag        | 00:58:22.786025
replay_lag       | 00:58:27.794622
sync_priority    | 0
sync_state       | async

postgres-# \q
bash-4.2$ exit
exit
[root@master vagrant]# exit
exit
[vagrant@master ~]$ exit
logout
Connection to 127.0.0.1 closed.
```

- Проверяем статус работы сервера бэкапа: 
```
[root@s01-deron lab27]# vagrant ssh backup
Last login: Sat Jan 16 14:17:05 2021 from 10.0.2.2
[vagrant@backup ~]$ sudo -s
[root@backup vagrant]# su barman
bash-4.2$ barman check master
Server master:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK
```

- Создаем бекап:
```
bash-4.2$ barman backup master --wait
Starting backup using postgres method for server master in /var/lib/barman/master/base/20210116T152241
Backup start at LSN: 0/12013F78 (000000010000000000000012, 00013F78)
Starting backup copy via pg_basebackup for 20210116T152241
Copy done (time: 3 seconds)
Finalising the backup.
This is the first backup for server master
WAL segments preceding the current backup have been found:
	000000010000000000000011 from server master has been removed
Backup size: 302.7 MiB
Backup end at LSN: 0/14000000 (000000010000000000000013, 00000000)
Backup completed (start time: 2021-01-16 15:22:41.233145, elapsed time: 3 seconds)
Waiting for the WAL file 000000010000000000000013 from server 'master'
Processing xlog segments from streaming for master
	000000010000000000000012
Processing xlog segments from streaming for master
	000000010000000000000013

bash-4.2$ barman list-backup master
master 20210116T152241 - Sat Jan 16 12:22:44 2021 - Size: 318.7 MiB - WAL Size: 0 B

bash-4.2$ barman check master
Server master:
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 1 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	continuous archiving: OK
	archiver errors: OK
```

## **Полезное:**

