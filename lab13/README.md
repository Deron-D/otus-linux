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


## **Полезное:**

semanage port -l | grep http

http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989


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


https://www.nginx.com/blog/using-nginx-plus-with-selinux/
https://wismutlabs.com/blog/fiddling-with-selinux-policies/

