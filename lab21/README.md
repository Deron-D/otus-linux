# **Домашнее задание №21: OSPF**

## **Задание:**

OSPF
- Поднять три виртуалки
- Объединить их разными vlan
1. Поднять OSPF между машинами на базе Quagga
2. Изобразить ассиметричный роутинг
3. Сделать один из линков "дорогим", но что бы при этом роутинг был симметричным

Формат сдачи:
Vagrantfile + ansible

---

## **Выполнено:**

### Схема сети:

![Схема сети](ospfv2.png)

- Поднимаем стенд:
```
vagrant up
```

- Проверяем таблицы маршутизации на машинах:
```
[root@s01-deron lab21]# vagrant ssh r1
Last login: Fri Jan 15 20:03:22 2021 from 10.0.2.2
[vagrant@r1 ~]$ ip ro
default via 10.0.2.2 dev eth0 proto dhcp metric 100
10.0.0.2 via 172.16.2.3 dev eth2 proto zebra metric 50
10.0.0.3 via 172.16.2.3 dev eth2 proto zebra metric 30
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100
172.16.1.0/24 dev eth1 proto kernel scope link src 172.16.1.1 metric 101
172.16.2.0/24 dev eth2 proto kernel scope link src 172.16.2.1 metric 102
172.16.3.0/24 via 172.16.2.3 dev eth2 proto zebra metric 40
[vagrant@r1 ~]$ exit
logout
Connection to 127.0.0.1 closed.

[root@s01-deron lab21]# vagrant ssh r2
Last login: Fri Jan 15 20:03:22 2021 from 10.0.2.2
[vagrant@r2 ~]$ ip ro
default via 172.16.1.1 dev eth1 proto zebra metric 1
10.0.0.1 via 172.16.1.1 dev eth1 proto zebra metric 30
10.0.0.3 via 172.16.3.3 dev eth2 proto zebra metric 30
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 103
172.16.1.0/24 dev eth1 proto kernel scope link src 172.16.1.2 metric 101
172.16.2.0/24 proto zebra metric 40
        nexthop via 172.16.1.1 dev eth1 weight 1
        nexthop via 172.16.3.3 dev eth2 weight 1
172.16.3.0/24 dev eth2 proto kernel scope link src 172.16.3.2 metric 102
[vagrant@r2 ~]$ exit
logout
Connection to 127.0.0.1 closed.

[root@s01-deron lab21]# vagrant ssh r3
Last login: Fri Jan 15 20:03:22 2021 from 10.0.2.2
[vagrant@r3 ~]$ ip ro
default via 172.16.2.1 dev eth1 proto zebra metric 1
10.0.0.1 via 172.16.2.1 dev eth1 proto zebra metric 30
10.0.0.2 via 172.16.3.2 dev eth2 proto zebra metric 30
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 103
172.16.1.0/24 via 172.16.3.2 dev eth2 proto zebra metric 40
172.16.2.0/24 dev eth1 proto kernel scope link src 172.16.2.3 metric 101
172.16.3.0/24 dev eth2 proto kernel scope link src 172.16.3.3 metric 102
[vagrant@r3 ~]$
```

- Проверяем настройку ассиметричной маршутизации:
```
[root@r2 vagrant]# tcpdump -nv -ieth1 icmp

[root@r1 vagrant]# tracepath -n 10.0.0.2
 1?: [LOCALHOST]                                         pmtu 1500
 1:  172.16.2.3                                            1.222ms
 1:  172.16.2.3                                            0.854ms
 2:  172.16.2.3                                            0.746ms !H
     Resume: pmtu 1500
```

- Восстанавливаем симметричную маршрутизацию не уменьшая цену интерфейса из предыдущего пункта:
```
[root@r1 vagrant]# vtysh

Hello, this is Quagga (version 0.99.22.4).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

r1# configure  terminal
r1(config)# interface  eth2
r1(config-if)# ip ospf  cost  1000
r1(config-if)# exit
r1(config)# exit
r1# exit

[root@r1 vagrant]# tracepath -n 10.0.0.2
 1?: [LOCALHOST]                                         pmtu 1500
 1:  10.0.0.2                                              1.411ms !H
 1:  10.0.0.2                                              0.900ms !H
     Resume: pmtu 1500

[root@r2 vagrant]# tcpdump -nv -ieth1 icmp
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
00:32:18.649857 IP (tos 0xc0, ttl 64, id 41716, offset 0, flags [none], proto ICMP (1), length 576)
    10.0.0.2 > 172.16.1.1: ICMP host 10.0.0.2 unreachable - admin prohibited, length 556
        IP (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto UDP (17), length 1500)
    172.16.1.1.36144 > 10.0.0.2.44444: UDP, length 1472
00:32:18.650758 IP (tos 0xc0, ttl 64, id 41717, offset 0, flags [none], proto ICMP (1), length 576)
    10.0.0.2 > 172.16.1.1: ICMP host 10.0.0.2 unreachable - admin prohibited, length 556
        IP (tos 0x0, ttl 1, id 0, offset 0, flags [DF], proto UDP (17), length 1500)
```

## **Полезное:**

[Методичка от ОТУС](https://github.com/mbfx/otus-linux-adm/blob/master/dynamic_routing_guideline/README.md)
