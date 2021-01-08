# **Домашнее задание №24: Сетевые пакеты. VLAN'ы. LACP**

## **Задание:**
Строим бонды и вланы
в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами
в internal сети testLAN
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1
- testServer2- 10.10.10.1

развести вланами
testClient1 <-> testServer1
testClient2 <-> testServer2

между centralRouter и inetRouter
"пробросить" 2 линка (общая inernal сеть) и объединить их в бонд
проверить работу c отключением интерфейсов

для сдачи - вагрант файл с требуемой конфигурацией
Разворачиваться конфигурация должна через ансибл

![Схема сети:](network23.png)

---

## **Выполнено:**

- Поднимаем стенд:
```
vagrant up
```

- Проверяем настройку vlan:
```
[root@s01-deron lab24]# vagrant ssh testClient1
[vagrant@testClient1 ~]$ nmcli con
NAME                UUID                                  TYPE      DEVICE
Wired connection 1  56445d0b-aedc-31d5-92a6-af6a277e7c52  ethernet  eth1
System eth0         5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
vlan100             0fdff289-2d6e-4ef9-82e3-9366f03cc5c3  vlan      eth1.100
[vagrant@testClient1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85967sec preferred_lft 85967sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:6f:74:45 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::2b7a:847e:770b:28d2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: eth1.100@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:6f:74:45 brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth1.100
       valid_lft forever preferred_lft forever
    inet6 fe80::2dc7:53d:2050:620b/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

[vagrant@testClient1 ~]$ ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.510 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.423 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.828 ms
...

root@s01-deron lab24]# vagrant ssh testServer1
Last login: Fri Jan  8 14:50:50 2021 from 10.0.2.2
[vagrant@testServer1 ~]$ nmcli con
NAME                UUID                                  TYPE      DEVICE
Wired connection 1  a1297d59-98a7-3de4-bb83-0ca009a68620  ethernet  eth1
System eth0         5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
vlan100             ecec62c4-bbb6-4f3c-b3a4-af17776ae437  vlan      eth1.100

[vagrant@testServer1 ~]$ sudo -s

[root@testServer1 vagrant]# tcpdump -nvvv -ieth1.100 icmp
tcpdump: listening on eth1.100, link-type EN10MB (Ethernet), capture size 262144 bytes
15:00:28.714010 IP (tos 0x0, ttl 64, id 22050, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.10.1 > 10.10.10.254: ICMP echo request, id 3264, seq 127, length 64
15:00:28.714042 IP (tos 0x0, ttl 64, id 28059, offset 0, flags [none], proto ICMP (1), length 84)
    10.10.10.254 > 10.10.10.1: ICMP echo reply, id 3264, seq 127, length 64
15:00:29.715034 IP (tos 0x0, ttl 64, id 22942, offset 0, flags [DF], proto ICMP (1), length 84)

[root@s01-deron lab24]# vagrant ssh testClient2
Last login: Fri Jan  8 14:50:51 2021 from 10.0.2.2
[vagrant@testClient2 ~]$ nmcli con
NAME                UUID                                  TYPE      DEVICE
System eth0         5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
vlan101             31949693-5764-462e-af51-89da1045750c  vlan      eth1.101
Wired connection 1  96e554b5-784a-3f26-a1f4-1ff5b44abe3a  ethernet  eth1
[vagrant@testClient2 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85702sec preferred_lft 85702sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:1b:39:0c brd ff:ff:ff:ff:ff:ff
    inet6 fe80::60a1:6388:55b8:584d/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: eth1.101@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:1b:39:0c brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth1.101
       valid_lft forever preferred_lft forever
    inet6 fe80::9d6a:a921:567b:e4c/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

[vagrant@testClient2 ~]$ ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.612 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.447 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.409 ms

[root@s01-deron lab24]# vagrant ssh testServer2
Last login: Fri Jan  8 14:50:50 2021 from 10.0.2.2
[vagrant@testServer2 ~]$ sudo -s
[root@testServer2 vagrant]# nmcli con
NAME                UUID                                  TYPE      DEVICE
System eth0         5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
vlan101             2f3beb98-f56e-4a65-b266-1a93b4fbbbc0  vlan      eth1.101
Wired connection 1  d10ba1a4-9d6a-3fbc-ac99-db450b19be5e  ethernet  eth1

[root@testServer2 vagrant]# tcpdump -nvvv -ieth1.101 icmp
tcpdump: listening on eth1.101, link-type EN10MB (Ethernet), capture size 262144 bytes
15:05:37.105863 IP (tos 0x0, ttl 64, id 22318, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.10.1 > 10.10.10.254: ICMP echo request, id 3313, seq 86, length 64
15:05:37.105895 IP (tos 0x0, ttl 64, id 24539, offset 0, flags [none], proto ICMP (1), length 84)
    10.10.10.254 > 10.10.10.1: ICMP echo reply, id 3313, seq 86, length 64
15:05:38.093836 IP (tos 0x0, ttl 64, id 22390, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.10.1 > 10.10.10.254: ICMP echo request, id 3313, seq 87, length 64
15:05:38.093867 IP (tos 0x0, ttl 64, id 24747, offset 0, flags [none], proto ICMP (1), length 84)
    10.10.10.254 > 10.10.10.1: ICMP echo reply, id 3313, seq 87, length 64
15:05:39.081386 IP (tos 0x0, ttl 64, id 22753, offset 0, flags [DF], proto ICMP (1), length 84)
    10.10.10.1 > 10.10.10.254: ICMP echo request, id 3313, seq 88, length 64
15:05:39.081417 IP (tos 0x0, ttl 64, id 25280, offset 0, flags [none], proto ICMP (1), length 84)
    10.10.10.254 > 10.10.10.1: ICMP echo reply, id 3313, seq 88, length 64
^C
6 packets captured
6 packets received by filter
0 packets dropped by kernel

```

- Проверяем настройку бонда:
```
[root@s01-deron lab24]# vagrant ssh inetRouter
Last login: Fri Jan  8 14:50:47 2021 from 10.0.2.2
[vagrant@inetRouter ~]$ nmcli con
NAME         UUID                                  TYPE      DEVICE
System eth0  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
Team0        404a03e0-6ec0-43df-aeb3-848d9ffbaf34  bond      Team0
Team-Port0   d65d5637-3896-41e8-8576-8993f30c3999  ethernet  eth1
Team-Port1   4fcb8e79-5bc0-45bf-bedf-ddc7e55a16d4  ethernet  eth2
[vagrant@inetRouter ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85332sec preferred_lft 85332sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master Team0 state UP group default qlen 1000
    link/ether 08:00:27:35:25:3f brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master Team0 state UP group default qlen 1000
    link/ether 08:00:27:35:25:3f brd ff:ff:ff:ff:ff:ff
5: Team0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:35:25:3f brd ff:ff:ff:ff:ff:ff
    inet 192.168.255.1/30 brd 192.168.255.3 scope global noprefixroute Team0
       valid_lft forever preferred_lft forever
    inet6 fe80::8b2f:6a81:e598:a4c6/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

[vagrant@inetRouter ~]$ ping  192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.273 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.397 ms
64 bytes from 192.168.255.2: icmp_seq=3 ttl=64 time=0.405 ms
64 bytes from 192.168.255.2: icmp_seq=4 ttl=64 time=0.415 ms

...
[root@s01-deron lab24]# vagrant ssh centralRouter
Last login: Fri Jan  8 14:50:47 2021 from 10.0.2.2
[vagrant@centralRouter ~]$ sudo -s
[root@centralRouter vagrant]# nmcli con
NAME                UUID                                  TYPE      DEVICE
Team0               edef109f-6756-401f-9aa4-fd089e5c9a25  bond      Team0
System eth0         5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
vlan100             bbaf6cbb-43fd-401e-b458-c6c1834cd312  vlan      eth3.100
vlan101             f10b439f-8b28-4333-8d43-2b070e04ef1d  vlan      eth3.101
Team-Port0          a4928b66-f1c6-44cf-9078-9d43276c82b6  ethernet  eth1
Team-Port1          983d7577-d80d-48d5-9b5b-411e7a010eac  ethernet  eth2
Wired connection 1  9862658d-e19c-3867-858a-b5b75b814e93  ethernet  --

[root@centralRouter vagrant]# tcpdump -nvvv -iTeam0 icmp
tcpdump: listening on Team0, link-type EN10MB (Ethernet), capture size 262144 bytes
15:13:06.502596 IP (tos 0x0, ttl 64, id 4457, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.255.1 > 192.168.255.2: ICMP echo request, id 3582, seq 146, length 64
15:13:06.502626 IP (tos 0x0, ttl 64, id 19635, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.255.2 > 192.168.255.1: ICMP echo reply, id 3582, seq 146, length 64
15:13:07.502849 IP (tos 0x0, ttl 64, id 4536, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.255.1 > 192.168.255.2: ICMP echo request, id 3582, seq 147, length 64
15:13:07.502887 IP (tos 0x0, ttl 64, id 20323, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.255.2 > 192.168.255.1: ICMP echo reply, id 3582, seq 147, length 64

[root@centralRouter vagrant]# ifdown eth2
Device 'eth2' successfully disconnected.

[root@centralRouter vagrant]# tcpdump -nvvv -iTeam0 icmp
tcpdump: listening on Team0, link-type EN10MB (Ethernet), capture size 262144 bytes
15:14:06.507812 IP (tos 0x0, ttl 64, id 33378, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.255.1 > 192.168.255.2: ICMP echo request, id 3582, seq 206, length 64
15:14:06.507842 IP (tos 0x0, ttl 64, id 51384, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.255.2 > 192.168.255.1: ICMP echo reply, id 3582, seq 206, length 64
15:14:07.507832 IP (tos 0x0, ttl 64, id 33862, offset 0, flags [DF], proto ICMP (1), length 84)
    192.168.255.1 > 192.168.255.2: ICMP echo request, id 3582, seq 207, length 64
15:14:07.507862 IP (tos 0x0, ttl 64, id 51746, offset 0, flags [none], proto ICMP (1), length 84)
    192.168.255.2 > 192.168.255.1: ICMP echo reply, id 3582, seq 207, length 64

```

## **Полезное:**

