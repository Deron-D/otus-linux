# **Проект**
Цель: Создание рабочего проекта
веб проект с развертыванием нескольких виртуальных машин
должен отвечать следующим требованиям
- включен https
- основная инфраструктура в DMZ зоне
- файрвалл на входе
- сбор метрик и настроенный алертинг
- везде включен selinux
- организован централизованный сбор логов

## **Тема:**

### **Развертывание защищенного окружения для публикации решений на платформе 1С**

Состав окружения:
- Сервер публикаций (nginx+apache?) (0%)
- Сервер приложений 1c v8.3 (0%)
- Сервер СУБД PostgreSQL (75%)
- Сервер реплики основной базы (100%)
- Сервер резервного копирования (Barman + Borg) (50%)
- Сервер логгирования и мониторинга (50%)
---

## **Выполнено:**


## **Полезное:**

- [Перенос базы PostgreSQL с сервера на сервер](https://shra.ru/2017/01/perenos-bazy-postgresql-s-servera-na-server/)
- [Простая установка 1С на Linux (Ubuntu)](https://wiseadvice-it.ru/o-kompanii/blog/articles/prostaya-ustanovka-1s-na-linux-ubuntu/)
- [Firewalld Rich and Direct Rules: Setting up RHEL 7 Server as a Router](https://www.lisenet.com/2016/firewalld-rich-and-direct-rules-setup-rhel-7-server-as-a-router/)
- [Firewalld : IP Masquerade](https://www.server-world.info/en/note?os=CentOS_7&p=firewalld&f=2)
- [Firewalld, установка и настройка, зоны, NAT, проброс портов](https://itproffi.ru/firewalld-ustanovka-i-nastrojka-zony-nat-probros-portov/)

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

