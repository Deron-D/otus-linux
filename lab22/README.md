# **Домашнее задание №22: Мосты, туннели и VPN**

## **Задание:**
1. Между двумя виртуалками поднять vpn в режимах
- tun
- tap
Прочуствовать разницу.

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку

3*. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке

---

## **Выполнено:**
1. Проверяем, что в файле provision/group_vars/all/all.yml переменной net_dev присвоено значение **tap** (Layer2)
```
[root@s01-deron lab22]# cat provision/group_vars/all/all.yml
---
net_dev: tap
```

2. Поднимаем стенд ```vagrant up``` с машинами :
- server
- client

3. Заходим на vpnserver и проверяем состояние интерфейсов:
``` 
[vagrant@vpnserver ~]$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic eth0
       valid_lft 85941sec preferred_lft 85941sec
    inet6 fe80::5054:ff:fe4d:77d3/64 scope link
       valid_lft forever preferred_lft forever
3: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN group default qlen 100
    link/ether 1e:a2:c5:3d:44:2f brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global tap0
       valid_lft forever preferred_lft forever
    inet6 fe80::1ca2:c5ff:fe3d:442f/64 scope link
       valid_lft forever preferred_lft forever
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:35:27:94 brd ff:ff:ff:ff:ff:ff
    inet 192.168.11.100/24 brd 192.168.11.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe35:2794/64 scope link
       valid_lft forever preferred_lft forever
```

4. На openvpn клиенте запускаем iperf3 в режиме клиента и замеряем
скорость в туннеле:
```
vagrant@client ~]$ iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 57994 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec   122 MBytes   204 Mbits/sec   39   1.21 MBytes
[  4]   5.00-10.01  sec   124 MBytes   207 Mbits/sec  604    281 KBytes
[  4]  10.01-15.00  sec   129 MBytes   216 Mbits/sec    0    511 KBytes
[  4]  15.00-20.00  sec   129 MBytes   216 Mbits/sec    0    664 KBytes
[  4]  20.00-25.00  sec   125 MBytes   210 Mbits/sec  243    473 KBytes
[  4]  25.00-30.00  sec   128 MBytes   214 Mbits/sec    0    636 KBytes
[  4]  30.00-35.00  sec   116 MBytes   195 Mbits/sec  302    297 KBytes
[  4]  35.00-40.00  sec   125 MBytes   210 Mbits/sec    0    512 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.00  sec   997 MBytes   209 Mbits/sec  1188             sender
[  4]   0.00-40.00  sec   993 MBytes   208 Mbits/sec                  receiver
```

5. На openvpn сервере запускаем:
```
[vagrant@vpnserver ~]$ ping 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=0.741 ms
64 bytes from 10.10.10.2: icmp_seq=2 ttl=64 time=1.09 ms
64 bytes from 10.10.10.2: icmp_seq=3 ttl=64 time=1.14 ms
64 bytes from 10.10.10.2: icmp_seq=4 ttl=64 time=2.13 ms
64 bytes from 10.10.10.2: icmp_seq=5 ttl=64 time=1.19 ms
```

6. На клиенте проверяем, что туннель через tap работает на Layer2:
```
[vagrant@client ~]$ sudo -s
[root@client vagrant]# tcpdump -i tap0 -q -e
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on tap0, link-type EN10MB (Ethernet), capture size 262144 bytes
12:42:34.066082 1e:a2:c5:3d:44:2f (oui Unknown) > 56:f0:ea:43:0b:66 (oui Unknown), IPv4, length 98: 10.10.10.1 > client: ICMP echo request, id 1067, seq 74, length 64
12:42:34.066104 56:f0:ea:43:0b:66 (oui Unknown) > 1e:a2:c5:3d:44:2f (oui Unknown), IPv4, length 98: client > 10.10.10.1: ICMP echo reply, id 1067, seq 74, length 64
12:42:35.069827 1e:a2:c5:3d:44:2f (oui Unknown) > 56:f0:ea:43:0b:66 (oui Unknown), IPv4, length 98: 10.10.10.1 > client: ICMP echo request, id 1067, seq 75, length 64
12:42:35.069868 56:f0:ea:43:0b:66 (oui Unknown) > 1e:a2:c5:3d:44:2f (oui Unknown), IPv4, length 98: client > 10.10.10.1: ICMP echo reply
```

7. Присваиваем в файле provision/group_vars/all/all.yml переменной net_dev значение **tun** (Layer3) и выполняем провижн стенда ```vagrant provision```

8. Проверяем на сервере:
```
[vagrant@vpnserver ~]$ ip l
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:4d:77:d3 brd ff:ff:ff:ff:ff:ff
3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 100
    link/none
4: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:35:27:94 brd ff:ff:ff:ff:ff:ff
```

9. Замеряем скорость на клиенте:
```
[vagrant@client ~]$ iperf3 -c 10.10.10.1 -t 40 -i 5
Connecting to host 10.10.10.1, port 5201
[  4] local 10.10.10.2 port 48644 connected to 10.10.10.1 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-5.00   sec   108 MBytes   182 Mbits/sec  400    501 KBytes
[  4]   5.00-10.00  sec   107 MBytes   179 Mbits/sec  143    402 KBytes
[  4]  10.00-15.01  sec   110 MBytes   185 Mbits/sec    0    566 KBytes
[  4]  15.01-20.00  sec   116 MBytes   195 Mbits/sec  163    449 KBytes
[  4]  20.00-25.00  sec   122 MBytes   204 Mbits/sec    0    614 KBytes
[  4]  25.00-30.00  sec   120 MBytes   201 Mbits/sec   78    259 KBytes
[  4]  30.00-35.00  sec   118 MBytes   198 Mbits/sec    0    488 KBytes
[  4]  35.00-40.01  sec   126 MBytes   210 Mbits/sec   40    485 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-40.01  sec   926 MBytes   194 Mbits/sec  824             sender
[  4]   0.00-40.01  sec   925 MBytes   194 Mbits/sec                  receiver

iperf Done.
```
**Скорость в туннеле через tap незначительно быстрее**

10. Запускаем на сервере:
```
[vagrant@vpnserver ~]$ ping 10.10.10.2
PING 10.10.10.2 (10.10.10.2) 56(84) bytes of data.
64 bytes from 10.10.10.2: icmp_seq=1 ttl=64 time=1.55 ms
64 bytes from 10.10.10.2: icmp_seq=2 ttl=64 time=1.12 ms
64 bytes from 10.10.10.2: icmp_seq=3 ttl=64 time=1.43 ms
```

11. Проверяем на клиенте, что tun работает только на Layer3:
```
[root@client vagrant]# tcpdump -i tun0 -q -e
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on tun0, link-type RAW (Raw IP), capture size 262144 bytes
12:53:52.612532 ip: 10.10.10.1 > client: ICMP echo request, id 1033, seq 104, length 64
12:53:52.612550 ip: client > 10.10.10.1: ICMP echo reply, id 1033, seq 104, length 64
12:53:53.615007 ip: 10.10.10.1 > client: ICMP echo request, id 1033, seq 105, length 64
12:53:53.615042 ip: client > 10.10.10.1: ICMP echo reply, id 1033, seq 105, length 64
```

12. Поднимаем стенд RAS на базе OpenVPN
```
cd ras
vagrant up
```

13. Подключаемся к openvpn серверу с хост-машины и проверяем:
```
[root@s01-deron ras]# cd client/

[root@s01-deron client]# openvpn --config client.conf --daemon

[root@s01-deron client]# ping -c 4 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=1.10 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=1.29 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=1.02 ms
64 bytes from 10.10.10.1: icmp_seq=4 ttl=64 time=0.487 ms

--- 10.10.10.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.487/0.976/1.291/0.300 ms

[root@s01-deron client]# ip r
default via 192.168.0.250 dev eno1 proto dhcp metric 100
10.10.10.0/24 via 10.10.10.5 dev tun0
10.10.10.5 dev tun0 proto kernel scope link src 10.10.10.6
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1
172.18.0.0/16 dev br-985c181c43e7 proto kernel scope link src 172.18.0.1
172.19.0.0/16 dev br-01572f432baa proto kernel scope link src 172.19.0.1
172.20.0.0/16 dev br-aba66c61482e proto kernel scope link src 172.20.0.1
172.21.0.0/16 dev br-7f3f5f7fc3eb proto kernel scope link src 172.21.0.1
192.168.0.0/24 dev eno1 proto kernel scope link src 192.168.0.243 metric 100
192.168.11.0/24 dev vboxnet3 proto kernel scope link src 192.168.11.1
```

## **Полезное:**

[Reference manual for OpenVPN 2.4](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/)
