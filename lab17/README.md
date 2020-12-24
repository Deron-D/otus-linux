# **Домашнее задание №17:Резервное копирование**

## **Задание:**
Настраиваем бэкапы
Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client

Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

- Директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB.
- Репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение
- Имя бекапа должно содержать информацию о времени снятия бекапа
- Глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов
- Резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации.
- Написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение.
- Настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов

Запустите стенд на 30 минут. Убедитесь что резервные копии снимаются. Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа. Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.

---

## **Выполнено:**

- Поднимаем стенд
```
vagrant up
```

- Проверяем:
```
[root@s01-deron lab17]# vagrant ssh client
[vagrant@client ~]$ sudo -s

[root@client vagrant]# systemctl status backup
● backup.service - My backup service
   Loaded: loaded (/etc/systemd/system/backup.service; static; vendor preset: disabled)
   Active: inactive (dead) since Wed 2020-12-23 19:38:58 UTC; 2min 31s ago
  Process: 26652 ExecStart=/opt/backup.sh (code=exited, status=0/SUCCESS)
 Main PID: 26652 (code=exited, status=0/SUCCESS)

Dec 23 19:38:49 client systemd[1]: Starting My backup service...
Dec 23 19:38:55 client backup.sh[26652]: borg 1.1.14
Dec 23 19:38:55 client backup.sh[26652]: Starting backup for 2020-12-23-client
Dec 23 19:38:56 client backup.sh[26652]: Creating archive at "backup@backupserver:/var/backup/client-etc::...:%S}"
Dec 23 19:38:56 client backup.sh[26652]: Completed backup for 2020-12-23-client
Dec 23 19:38:57 client backup.sh[26652]: Keeping archive: etc_backup-2020-12-23_19:38:55       Wed, 2020-1...4fd0]
Dec 23 19:38:57 client backup.sh[26652]: Pruning archive: etc_backup-2020-12-23_19:33:47       Wed, 2020-1...(1/1)
Dec 23 19:38:58 client backup.sh[26652]: terminating with success status, rc 0
Dec 23 19:38:58 client systemd[1]: Started My backup service.
Hint: Some lines were ellipsized, use -l to show in full.

[root@client vagrant]# systemctl status backup.timer
● backup.timer - Run backup script every 5 minutes
   Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-12-23 15:51:38 UTC; 3h 52min ago

Dec 23 15:51:38 client systemd[1]: Started Run backup script every 5 minutes.[root@client vagrant]# systemctl status backup.timer

[root@client vagrant]# systemctl list-timers
NEXT                         LEFT          LAST PASSED UNIT                         ACTIVATES
Thu 2020-12-24 12:37:47 UTC  2min 15s left n/a  n/a    backup.timer                 backup.service
Thu 2020-12-24 12:46:41 UTC  11min left    n/a  n/a    systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

[root@client vagrant]# systemctl stop backup.timer

[root@client vagrant]#  borg list backup@backupserver:/var/backup/client-etc
Enter passphrase for key ssh://backup@backupserver/var/backup/client-etc:
etc_backup-2020-12-24_12-38-21       Thu, 2020-12-24 12:38:21 [e04783342f65542ac250d3e6eb93635b75fc6383dbf0089530b08e6b791f776a]
```

- Полное удаление /etc на client в жизни приводит к "дальней дороге" с подсказками из [Домашнее задание №6: Загрузка системы](https://github.com/Deron-D/otus-linux/tree/master/lab06) 
и подготовленным архивом из репозитория на backupserver:
```
[root@s01-deron lab17]# vagrant ssh backupserver
[vagrant@backupserver ~]$ sudo -s
[root@backupserver vagrant]# cd /home/backup/

[root@backupserver backup]# borg list /var/backup/client-etc/
Enter passphrase for key /var/backup/client-etc:
etc_backup-2020-12-24_12-44-21       Thu, 2020-12-24 12:44:21 [db435f8abac3c932d895af7a734dcc6300fc465cb1b1fdf4bc59b57b6fbf3938]

[root@backupserver backup]# borg extract /var/backup/client-etc/::etc_backup-2020-12-24_12-44-21
Enter passphrase for key /var/backup/client-etc:

[root@backupserver backup]# tar -czvpf client-etc.tar.gz /etc/

[root@backupserver backup]# ls -la client-etc*
-rw-r--r--. 1 root root 10333818 Dec 24 12:48 client-etc.tar.gz
```

- Ограничимся удалением и восстановлением /etc/cron.daily/
```
[root@client etc]# rm -r /etc/cron.daily/
rm: descend into directory ‘/etc/cron.daily/’? y
rm: remove regular file ‘/etc/cron.daily/logrotate’? y
rm: remove regular file ‘/etc/cron.daily/man-db.cron’? y
rm: remove directory ‘/etc/cron.daily/’? y

[root@client etc]# cd /

[root@client /]# borg extract backup@backupserver:/var/backup/client-etc::etc_backup-2020-12-24_12-50-21 etc/cron.daily
Enter passphrase for key ssh://backup@backupserver/var/backup/client-etc:

[root@client /]# ls -lr /etc/cron.daily
total 8
-rwxr-xr-x. 1 root root 618 Oct 30  2018 man-db.cron
-rwx------. 1 root root 219 Apr  1  2020 logrotate
```


## **Полезное:**

[Central repository Borg server with Ansible or Salt](https://borgbackup.readthedocs.io/en/stable/deployment/central-backup-server.html)

