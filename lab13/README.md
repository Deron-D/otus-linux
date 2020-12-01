# **Домашнее задание №13: Практика с SELinux**

## **Задание:**
Практика с SELinux
Цель: Тренируем умение работать с SELinux: диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.
1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.
К сдаче:
- README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.
- Развернуть приложенный стенд
https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems
- Выяснить причину неработоспособности механизма обновления зоны (см. README);
- Предложить решение (или решения) для данной проблемы;
- Выбрать одно из решений для реализации, предварительно обосновав выбор;
- Реализовать выбранное решение и продемонстрировать его работоспособность.
К сдаче:
- README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
- Исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.
Критерии оценки:
Обязательно для выполнения:
- 1 балл: для задания 1 описаны, реализованы и продемонстрированы все 3 способа решения;
- 1 балл: для задания 2 описана причина неработоспособности механизма обновления зоны;
- 1 балл: для задания 2 реализован и продемонстрирован один из способов решения;
Опционально для выполнения:
- 1 балл: для задания 2 предложено более одного способа решения;
- 1 балл: для задания 2 обоснованно(!) выбран один из способов решения.

---

## **Выполнено:**

## **1. Запустить nginx на нестандартном порту 3-мя разными способами:**

Поднимаем стенд для настройки и запуска nginx на нестандартном порту:
```bash
vagrant up
vagrant ssh
sudo -s
```

### **Способ 1. Переключатель параметризованной политики setbool:**
```
[root@lab13 vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

Dec 01 05:52:58 lab13 systemd[1]: Unit nginx.service cannot be reloaded because it is inactive.

[root@lab13 vagrant]# systemctl start nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
[root@lab13 vagrant]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[root@lab13 vagrant]# setenforce 0
[root@lab13 vagrant]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
[root@lab13 vagrant]# echo > /var/log/audit/audit.log
[root@lab13 vagrant]# systemctl start nginx
[root@lab13 vagrant]# audit2why <  /var/log/audit/audit.log
type=AVC msg=audit(1606820029.040:1343): avc:  denied  { name_bind } for  pid=24811 comm="nginx" src=5080 
scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=1

        Was caused by:
        The boolean nis_enabled was set incorrectly.
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1

[root@lab13 vagrant]# semanage boolean -l | grep nis_enabled
nis_enabled                    (off  ,  off)  Allow nis to enabled

[root@lab13 vagrant]# sesearch -s httpd_t -t unreserved_port_t -AC
Found 9 semantic av rules:
   allow httpd_t port_type : tcp_socket { recv_msg send_msg } ;
   allow httpd_t port_type : udp_socket { recv_msg send_msg } ;
DT allow nsswitch_domain port_type : tcp_socket { recv_msg send_msg } ; [ nis_enabled ]
DT allow nsswitch_domain unreserved_port_t : tcp_socket name_connect ; [ nis_enabled ]
DT allow nsswitch_domain unreserved_port_t : tcp_socket name_bind ; [ nis_enabled ]
DT allow httpd_t port_type : tcp_socket name_connect ; [ httpd_can_network_connect ]
DT allow nsswitch_domain port_type : udp_socket recv_msg ; [ nis_enabled ]
DT allow nsswitch_domain port_type : udp_socket send_msg ; [ nis_enabled ]
DT allow nsswitch_domain unreserved_port_t : udp_socket name_bind ; [ nis_enabled ]

[root@lab13 vagrant]# setenforce 1
[root@lab13 vagrant]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31

[root@lab13 vagrant]# getsebool nis_enabled
nis_enabled --> off
[root@lab13 vagrant]# setsebool -P nis_enabled 1
[root@lab13 vagrant]# getsebool nis_enabled
nis_enabled --> on

[root@lab13 vagrant]# systemctl restart nginx

[root@lab13 vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-12-01 12:33:34 UTC; 2s ago
  Process: 25116 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25114 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25112 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25118 (nginx)
   CGroup: /system.slice/nginx.service
           ├─25118 nginx: master process /usr/sbin/nginx
           └─25119 nginx: worker process

```

### **Способ 2. Добавление нестандартного порта в имеющийся тип:**
```
[root@lab13 vagrant]# setsebool -P nis_enabled 0

[root@lab13 vagrant]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

[root@lab13 vagrant]# semanage  port -l | grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988

[root@lab13 vagrant]# semanage port -a -t http_port_t -p tcp 5080

[root@lab13 vagrant]# semanage  port -l | grep http_port_t
http_port_t                    tcp      5080, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988

[root@lab13 vagrant]# systemctl restart nginx

[root@lab13 vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-12-01 12:41:18 UTC; 4s ago
  Process: 25162 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25160 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25159 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25164 (nginx)
   CGroup: /system.slice/nginx.service
           ├─25164 nginx: master process /usr/sbin/nginx
           └─25165 nginx: worker process

```

### **Способ 3. Формирование и установка модуля SELinux**
```
[root@lab13 vagrant]# semanage port -d -t http_port_t -p tcp 5080

[root@lab13 vagrant]# semanage  port -l | grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988

[root@lab13 vagrant]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

[root@lab13 vagrant]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31

[root@lab13 vagrant]# setenforce 0

[root@lab13 vagrant]# echo > /var/log/audit/audit.log

[root@lab13 vagrant]# systemctl restart nginx

[root@lab13 vagrant]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx_add
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx_add.pp

[root@lab13 vagrant]# cat nginx_add.te

module nginx_add 1.0;

require {
        type httpd_t;
        type unreserved_port_t;
        class tcp_socket name_bind;
}

#============= httpd_t ==============

#!!!! This avc can be allowed using the boolean 'nis_enabled'
allow httpd_t unreserved_port_t:tcp_socket name_bind;

[root@lab13 vagrant]# semodule -i nginx_add.pp

[root@lab13 vagrant]# semodule -l | grep nginx
nginx_add       1.0

[root@lab13 vagrant]# setenforce 1

[root@lab13 vagrant]# systemctl restart nginx

[root@lab13 vagrant]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-12-01 12:54:33 UTC; 6s ago
  Process: 25266 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25264 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25263 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25268 (nginx)
   CGroup: /system.slice/nginx.service
           ├─25268 nginx: master process /usr/sbin/nginx
           └─25269 nginx: worker process

```

## **2. Обеспечить работоспособность приложения(named) при включенном selinux.**

Поднимаем стенд для настройки и запуска nginx на нестандартном порту:
```bash
cd selinux_dns_problems/
vagrant up
```

Заходим на ns01 и проводим подготовительную настройку для анализа проблемы:
```
[root@s01-deron selinux_dns_problems]# vagrant ssh ns01
Last login: Tue Dec  1 13:13:29 2020 from 10.0.2.2
[vagrant@ns01 ~]$ sudo -s
[root@ns01 vagrant]# sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31

[root@ns01 vagrant]# setenforce 0

[root@ns01 vagrant]# getenforce
Permissive

[root@ns01 vagrant]# echo > /var/log/audit/audit.log
```

Заходим на client и пытаемся внести изменения в зону ddns.lab:
```
vagrant ssh client
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
```

Анализируем проблему на ns01:
```
[root@ns01 vagrant]# audit2why < /var/log/audit/audit.log
type=AVC msg=audit(1606829016.399:1867): avc:  denied  { create } for  pid=4870 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

type=AVC msg=audit(1606829016.399:1867): avc:  denied  { write } for  pid=4870 comm="isc-worker0000" path="/etc/named/dynamic/named.ddns.lab.view1.jnl" dev="sda1" ino=464981 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=1

        Was caused by:
                Missing type enforcement (TE) allow rule.

                You can use audit2allow to generate a loadable module to allow this access.

[root@ns01 vagrant]# sesearch -s named_t  -A | grep 'allow named_t' | grep etc_t
   allow named_t etc_t : dir { ioctl read write getattr lock add_name remove_name search open } ;
   allow named_t etc_t : lnk_file { read getattr } ;

[root@ns01 vagrant]# cat /etc/selinux/targeted/contexts/files/file_contexts | grep named_
...
/var/named(/.*)?        system_u:object_r:named_zone_t:s0
/var/named/dynamic(/.*)?        system_u:object_r:named_cache_t:s0
...


[root@ns01 vagrant]# sesearch -s named_t  -A -c file| grep 'allow named_t' | grep named_zone_t
   allow named_t named_zone_t : file { ioctl read getattr lock open } ;
   allow named_t named_zone_t : file { ioctl read write create getattr setattr lock append unlink link rename open } ;
[root@ns01 vagrant]# sesearch -s named_t  -A -c file| grep 'allow named_t' | grep named_cache_t
   allow named_t named_cache_t : file { ioctl read write create getattr setattr lock append unlink link rename open } ;
```

# Решение проблемы (способ 1, предпочтительный, т.к. не нужно компилировать и подгружать модуль):

На ns01:
```
[root@ns01 vagrant]# semanage fcontext -l | grep named_cache_t
/var/named/data(/.*)?                              all files          system_u:object_r:named_cache_t:s0
/var/lib/softhsm(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/lib/unbound(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/named/slaves(/.*)?                            all files          system_u:object_r:named_cache_t:s0
/var/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/tmp(/.*)?                    all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/data(/.*)?             all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/slaves(/.*)?           all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/dynamic(/.*)?          all files          system_u:object_r:named_cache_t:s0

[root@ns01 vagrant]# ls -Z /etc/named/dynamic/
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1

[root@ns01 vagrant]# semanage fcontext -a -t named_cache_t "/etc/named/dynamic(/.*)?"

[root@ns01 vagrant]# semanage fcontext -l | grep named_cache_t
/var/named/data(/.*)?                              all files          system_u:object_r:named_cache_t:s0
/var/lib/softhsm(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/lib/unbound(/.*)?                             all files          system_u:object_r:named_cache_t:s0
/var/named/slaves(/.*)?                            all files          system_u:object_r:named_cache_t:s0
/var/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/tmp(/.*)?                    all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/data(/.*)?             all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/slaves(/.*)?           all files          system_u:object_r:named_cache_t:s0
/var/named/chroot/var/named/dynamic(/.*)?          all files          system_u:object_r:named_cache_t:s0
/etc/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0

[root@ns01 vagrant]# restorecon -Rv /etc/named/dynamic
restorecon reset /etc/named/dynamic context unconfined_u:object_r:etc_t:s0->unconfined_u:object_r:named_cache_t:s0
restorecon reset /etc/named/dynamic/named.ddns.lab context system_u:object_r:etc_t:s0->system_u:object_r:named_cache_t:s0
restorecon reset /etc/named/dynamic/named.ddns.lab.view1 context system_u:object_r:etc_t:s0->system_u:object_r:named_cache_t:s0

[root@ns01 vagrant]# ls -Z /etc/named/dynamic/
-rw-rw----. named named system_u:object_r:named_cache_t:s0 named.ddns.lab
-rw-rw----. named named system_u:object_r:named_cache_t:s0 named.ddns.lab.view1

[root@ns01 vagrant]# setenforce 1

[root@ns01 vagrant]# getenforce
Enforcing
```

Проверяем на client:
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add ftp.ddns.lab. 60 A 192.168.50.55
> send
> quit

[vagrant@client ~]$  dig @192.168.50.10 ftp.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.2 <<>> @192.168.50.10 ftp.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13378
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;ftp.ddns.lab.                  IN      A

;; ANSWER SECTION:
ftp.ddns.lab.           60      IN      A       192.168.50.55

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Tue Dec 01 15:42:50 UTC 2020
;; MSG SIZE  rcvd: 96

```


# Решение проблемы (способ 2, формирование модуля):

На ns01:
```
[root@ns01 vagrant]# chcon -v -R --type=etc_t /etc/named/dynamic/
changing security context of '/etc/named/dynamic/named.ddns.lab'
changing security context of '/etc/named/dynamic/named.ddns.lab.view1'
changing security context of '/etc/named/dynamic/named.ddns.lab.view1.jnl'
changing security context of '/etc/named/dynamic/'

[root@ns01 vagrant]# ls -Z /etc/named/dynamic/
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
-rw-r--r--. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
-rw-r--r--. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1.jnl

[root@ns01 vagrant]# audit2allow -M named_add --debug < /var/log/audit/audit.log

module named_add 1.0;

require {
        type etc_t;
        type named_t;
        class file { create rename unlink write };
}

#============= named_t ==============

#!!!! WARNING: 'etc_t' is a base type.
allow named_t etc_t:file { create rename unlink write };
[root@ns01 vagrant]# audit2allow -M named_add --debug < /var/log/audit/audit.log
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i named_add.pp

[root@ns01 vagrant]# semodule -i named_add.pp

[root@ns01 vagrant]# semodule -l | grep  named_add
named_add       1.0

```

Проверяем на client:
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add nfs.ddns.lab. 60 A 192.168.50.66
> send
> quit

[vagrant@client ~]$ dig @192.168.50.10 nfs.ddns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.2 <<>> @192.168.50.10 nfs.ddns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5885
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;nfs.ddns.lab.                  IN      A

;; ANSWER SECTION:
nfs.ddns.lab.           60      IN      A       192.168.50.66

;; AUTHORITY SECTION:
ddns.lab.               3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10

;; Query time: 3 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Tue Dec 01 14:22:00 UTC 2020
;; MSG SIZE  rcvd: 96
```



## **Полезное:**
```
seinfo --portcon=80
	portcon tcp 80 system_u:object_r:http_port_t:s0
	portcon tcp 1-511 system_u:object_r:reserved_port_t:s0
	portcon udp 1-511 system_u:object_r:reserved_port_t:s0
	portcon sctp 1-511 system_u:object_r:reserved_port_t:s0


export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

sealert -a /var/log/audit/audit.log
ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000
semodule -i my-iscworker0000.pp
```

https://wiki.gentoo.org/wiki/SELinux/Tutorials/Using_SELinux_booleans

https://www.nginx.com/blog/using-nginx-plus-with-selinux/

https://wismutlabs.com/blog/fiddling-with-selinux-policies/

https://www.digitalocean.com/community/tutorials/an-introduction-to-selinux-on-centos-7-part-3-users

