# **Домашнее задание №23: DNS- настройка и обслуживание**

## **Задание:**

настраиваем split-dns
взять стенд https://github.com/erlong15/vagrant-bind
добавить еще один сервер client2
завести в зоне dns.lab
имена
web1 - смотрит на клиент1
web2 смотрит на клиент2

завести еще одну зону newdns.lab
завести в ней запись
www - смотрит на обоих клиентов

настроить split-dns
клиент1 - видит обе зоны, но в зоне dns.lab только web1

клиент2 видит только dns.lab

*) настроить все без выключения selinux
Критерии оценки: 4 - основное задание сделано, но есть вопросы
5 - сделано основное задание
6 - выполнено задания со звездочкой

---

## **Выполнено:**

#### Поднимаем стенд:
```
git clone https://github.com/Deron-D/otus-linux && cd otus-linux/lab23 && vagrant up
```

#### Проверяем на client:
```
[vagrant@client ~]$ dig @192.168.50.10 web1.dns.lab +short
192.168.50.15
[vagrant@client ~]$ dig @192.168.50.10 web2.dns.lab +short
[vagrant@client ~]$ dig @192.168.50.10 www.newdns.lab +short
192.168.50.15
192.168.50.22
[vagrant@client ~]$ dig @192.168.50.11 web1.dns.lab +short
192.168.50.15
[vagrant@client ~]$ dig @192.168.50.11 web2.dns.lab +short
[vagrant@client ~]$ dig @192.168.50.11 www.newdns.lab +short
192.168.50.22
192.168.50.15
[vagrant@client ~]$ dig @192.168.50.10 -x 192.168.50.15 +short
web1.dns.lab.
[vagrant@client ~]$ dig @192.168.50.10 -x 192.168.50.22 +short
web2.dns.lab.
[vagrant@client ~]$ dig @192.168.50.11 -x 192.168.50.15 +short
web1.dns.lab.
[vagrant@client ~]$ dig @192.168.50.11 -x 192.168.50.22 +short
web2.dns.lab.
```


#### Проверяем на client2:
```
[vagrant@client2 ~]$ dig @192.168.50.10 web1.dns.lab +short
192.168.50.15
[vagrant@client2 ~]$ dig @192.168.50.10 web2.dns.lab +short
192.168.50.22
[vagrant@client2 ~]$ dig @192.168.50.10 www.newdns.lab +short
[vagrant@client2 ~]$ dig @192.168.50.11 www.newdns.lab +short
[vagrant@client2 ~]$ dig @192.168.50.11 web1.dns.lab +short
192.168.50.15
[vagrant@client2 ~]$ dig @192.168.50.11 web2.dns.lab +short
192.168.50.22
[vagrant@client2 ~]$ dig @192.168.50.10 -x 192.168.50.15 +short
web1.dns.lab.
[vagrant@client2 ~]$ dig @192.168.50.10 -x 192.168.50.22 +short
web2.dns.lab.
[vagrant@client2 ~]$ dig @192.168.50.11 -x 192.168.50.22 +short
web2.dns.lab.
[vagrant@client2 ~]$ dig @192.168.50.11 -x 192.168.50.15 +short
web1.dns.lab.
```

## **Полезное:**

#### В случае запуска dnssec-keygen на Centos без указания /dev/urandom генерация ключей зависает,
поэтому:
```
dnssec-keygen -a HMAC-MD5 -b 128 -r /dev/urandom -n HOST zonetransfer2key | base64
```
