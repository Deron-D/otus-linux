# **Домашнее задание №25: LDAP**

## **Задание:**
LDAP
1. Установить FreeIPA;
2. Написать Ansible playbook для конфигурации клиента;
3*. Настроить аутентификацию по SSH-ключам;
4**. Firewall должен быть включен на сервере и на клиенте.

В git - результирующий playbook.

---

## **Выполнено:**

#### Разворачиваем стенд:

```
git clone https://github.com/Deron-D/otus-linux && cd otus-linux/lab25 && git clone https://github.com/freeipa/ansible-freeipa.git && vagrant up && ansible-playbook playbook.yml
```

![Консоль FreeIPA](./png/freeipa.png)

```
[vagrant@ldapsrv ~]$ ipa user-add --first="Jinny" --last="Pattanajee" --cn="Jinny Pattanajee" --password jpattan --shell="/bin/bash"         Password:
Enter Password again to verify:
--------------------
Added user "jpattan"
--------------------
  User login: jpattan
  First name: Jinny
  Last name: Pattanajee
  Full name: Jinny Pattanajee
  Display name: Jinny Pattanajee
  Initials: JP
  Home directory: /home/jpattan
  GECOS: Jinny Pattanajee
  Login shell: /bin/bash
  Principal name: jpattan@OTUS.LAB
  Principal alias: jpattan@OTUS.LAB
  User password expiration: 20210125164942Z
  Email address: jpattan@otus.lab
  UID: 1139400003
  GID: 1139400003
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
```

```
[root@s01-deron lab25]# vagrant ssh client
Last login: Mon Jan 25 19:45:03 2021 from 10.0.2.2
[vagrant@client ~]$ su - jpattan
Password:
Password expired. Change your password now.
Current Password:
New password:
Retype new password:
Creating home directory for jpattan.

```

## **Полезное:**

