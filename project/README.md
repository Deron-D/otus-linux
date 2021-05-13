# **Проект**
Цель:
Создание рабочего проекта  
веб проект с развертыванием нескольких виртуальных машин должен отвечать следующим требованиям

- включен https
- основная инфраструктура в DMZ зоне
- файрвалл на входе
- сбор метрик и настроенный алертинг
- везде включен selinux
- организован централизованный сбор логов

## **Тема:**

### **Infrastructure as code на примере развертывания защищенного окружения для публикации решений на платформе 1С с реализацией централизованного сбора логов, мониторинга и резервного копирования**

---

## **Выполнено:**

**Состав окружения:**
- Frontend (nginx.otus.lab): [https://host:8443/1CDocDemo/ru_RU/](https://192.168.0.103:8443/1CDocDemo/ru_RU/)
- Сервер публикаций (apachehost.otus.lab)
- Сервер приложений 1c v8.3 (srv1c.otus.lab)
- Сервер СУБД PostgreSQL (master.otus.lab)
- Сервер реплики основной базы (slave.otus.lab)
- Сервер резервного копирования (Barman + Borg) (backup.otus.lab )
- Сервер системы мониторинга (zabbixhos.otus.lab): [http://host:2088/](http://192.168.0.103:2088/)
  Введите имя пользователя Admin с паролем zabbix для входа под Супер-Администратором Zabbix
- Сервер централизованного сбора логов: [http://host:5601/app/home#/](http://192.168.0.103:5601/app/home#/).
  Kibana index pattern пока нужно создавать вручную: [http://host:5601/app/management/kibana/indexPatterns/create](http://192.168.0.103:5601/app/management/kibana/indexPatterns/create)

![Схема стенда](net.png)

## **Полезное:**

**ELK**

Проверка работы базы данных:
```
curl -GET localhost:9200/_cat/health?v
```

ELK cluster state
```
curl -GET 'localhost:9200/_cluster/state?pretty'
```

Просмотр индексов в базе:
```
curl -GET localhost:9200/_cat/indices?v
```
- [Перенос базы PostgreSQL с сервера на сервер](https://shra.ru/2017/01/perenos-bazy-postgresql-s-servera-na-server/)
- [Простая установка 1С на Linux (Ubuntu)](https://wiseadvice-it.ru/o-kompanii/blog/articles/prostaya-ustanovka-1s-na-linux-ubuntu/)
- [Firewalld Rich and Direct Rules: Setting up RHEL 7 Server as a Router](https://www.lisenet.com/2016/firewalld-rich-and-direct-rules-setup-rhel-7-server-as-a-router/)
- [Firewalld : IP Masquerade](https://www.server-world.info/en/note?os=CentOS_7&p=firewalld&f=2)
- [Firewalld, установка и настройка, зоны, NAT, проброс портов](https://itproffi.ru/firewalld-ustanovka-i-nastrojka-zony-nat-probros-portov/)


