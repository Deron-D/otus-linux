# **Домашнее задание №8:ZFS**

## **Задание:**
Цель: Отрабатываем навыки работы с созданием томов export/import и установкой параметров. Определить алгоритм с наилучшим сжатием. Определить настройки pool’a Найти сообщение от преподавателей Результат: список команд которыми получен результат с их выводами
1. Определить алгоритм с наилучшим сжатием

Зачем:
Отрабатываем навыки работы с созданием томов и установкой параметров. Находим наилучшее сжатие.


Шаги:
- определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4)
- создать 4 файловых системы на каждой применить свой алгоритм сжатия
Для сжатия использовать либо текстовый файл либо группу файлов:
- скачать файл “Война и мир” и расположить на файловой системе
wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8
либо скачать файл ядра распаковать и расположить на файловой системе

Результат:
- список команд которыми получен результат с их выводами
- вывод команды из которой видно какой из алгоритмов лучше


2. Определить настройки pool’a

Зачем:
Для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS

Шаги:
- Загрузить архив с файлами локально.
https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
Распаковать.
- С помощью команды zfs import собрать pool ZFS.
- Командами zfs определить настройки
- размер хранилища
- тип pool
- значение recordsize
- какое сжатие используется
- какая контрольная сумма используется
Результат:
- список команд которыми восстановили pool . Желательно с Output команд.
- файл с описанием настроек settings

3. Найти сообщение от преподавателей

Зачем:
для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.

Шаги:
- Скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing
Файл был получен командой
zfs send otus/storage@task2 > otus_task2.file
- Восстановить файл локально. zfs receive
- Найти зашифрованное сообщение в файле secret_message

Результат:
- список шагов которыми восстанавливали
- зашифрованное сообщение

---

## **Выполнено:**

1. Определяем алгоритм с наилучшим сжатием  

- Поднимаем стенд, используя [Vagrantfile](Vagrantfile):
```
vagrant up
[root@s01-deron lab08]# vagrant ssh
[vagrant@zfstest ~]$ sudo -s
[root@zfstest vagrant]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
    └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
    sdb                       8:16   0  100M  0 disk
    sdc                       8:32   0  100M  0 disk
    sdd                       8:48   0  100M  0 disk
    sde                       8:64   0  100M  0 disk
    sdf                       8:80   0  100M  0 disk
    sdg                       8:96   0  100M  0 disk
```

- Создаем пул и ФС:
```
[root@zfstest vagrant]# zpool create mypool sdb sdc sdd sde sdf sdg
[root@zfstest vagrant]# zpool list
NAME     SIZE  ALLOC   FREE  EXPANDSZ   FRAG    CAP  DEDUP  HEALTH  ALTROOT
mypool   480M   106K   480M         -     0%     0%  1.00x  ONLINE  -
[root@zfstest vagrant]# zpool status
  pool: mypool
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        mypool      ONLINE       0     0     0
          sdb       ONLINE       0     0     0
          sdc       ONLINE       0     0     0
          sdd       ONLINE       0     0     0
          sde       ONLINE       0     0     0
          sdf       ONLINE       0     0     0
          sdg       ONLINE       0     0     0

errors: No known data errors
[root@zfstest vagrant]# for var in gzip gzip-9 lz4 zle lzjb; do zfs create mypool/$var;zfs set compression=$var mypool/$var; done
[root@zfstest vagrant]# for var in gzip gzip-9 lz4 zle lzjb; do zfs get -H compression mypool/$var; done
mypool/gzip     compression     gzip    local
mypool/gzip-9   compression     gzip-9  local
mypool/lz4      compression     lz4     local
mypool/zle      compression     zle     local
mypool/lzjb     compression     lzjb    local

[root@zfstest vagrant]# for var in gzip gzip-9 lz4 zle lzjb; do curl -o /mypool/$var/War_and_Peace.txt http://www.gutenberg.org/cache/epub/2600/pg2600.txt;done
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1181k  100 1181k    0     0   790k      0  0:00:01  0:00:01 --:--:--  791k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1181k  100 1181k    0     0   805k      0  0:00:01  0:00:01 --:--:--  805k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1181k  100 1181k    0     0   666k      0  0:00:01  0:00:01 --:--:--  666k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1181k  100 1181k    0     0   738k      0  0:00:01  0:00:01 --:--:--  738k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1181k  100 1181k    0     0   450k      0  0:00:02  0:00:02 --:--:--  450k

[root@zfstest vagrant]# zfs list -p -s used
NAME              USED      AVAIL    REFER  MOUNTPOINT
mypool/gzip    1237504  362777600  1237504  /mypool/gzip
mypool/lz4     1238016  362777600  1238016  /mypool/lz4
mypool/zle     1238016  362777600  1238016  /mypool/zle
mypool/gzip-9  1238528  362777600  1238528  /mypool/gzip-9
mypool/lzjb    1245184  362777600  1245184  /mypool/lzjb
mypool         6321152  362777600    30208  /mypool
```

Резюме: алгоритм с наилучшим сжатием - **gzip**


2. Определем настройки pool’a

- Скачиваем и распаковываем архив:
```
cd /vagrant
./download_gdrive 1KRBNW33QWqbvbVHa3hLJivOAt60yukkg zfs_task1.tar.gz
tar xvzf zfs_task1.tar.gz
zpool import -d ./zpoolexport/
zpool import -d ./zpoolexport/ otus
zpool list
[root@zfstest vagrant]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                            STATE     READ WRITE CKSUM
        otus                            ONLINE       0     0     0
          mirror-0                      ONLINE       0     0     0
            /vagrant/zpoolexport/filea  ONLINE       0     0     0
            /vagrant/zpoolexport/fileb  ONLINE       0     0     0
[root@zfstest vagrant]# zfs get recordsize,compression,checksum otus
NAME  PROPERTY     VALUE      SOURCE
otus  recordsize   128K       local
otus  compression  zle        local
otus  checksum     sha256     local
```

3. Найти сообщение от преподавателей:

```
cd /vagrant
./download_gdrive 1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG otus_task2.file
zfs receive otus/storage@task2 < otus_task2.file
[root@zfstest vagrant]# zfs list -t snapshot
NAME                 USED  AVAIL     REFER  MOUNTPOINT
otus/storage@task2    21K      -     2.83M  -
[root@zfstest vagrant]# find /otus -name "secret_message" -exec cat '{}' \;
https://github.com/sindresorhus/awesome

```

Сообщение - **https://github.com/sindresorhus/awesome**


## **Полезное:**

