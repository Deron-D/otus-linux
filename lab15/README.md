# **Домашнее задание №15: Настройка мониторинга **

## **Задание:**
Настройка мониторинга
Настроить дашборд с 4-мя графиками
1) память
2) процессор
3) диск
4) сеть

настроить на одной из систем
- zabbix (использовать screen (комплексный экран))
- prometheus - grafana

* использование систем примеры которых не рассматривались на занятии
- список возможных систем был приведен в презентации

в качестве результата прислать скриншот экрана - дашборд должен содержать в названии имя приславшего

---

## **Выполнено:**


```
ansible-galaxy install --roles-path ./roles/ cloudalchemy.prometheus
ansible-galaxy install --roles-path ./roles/ cloudalchemy.node-exporter
ansible-galaxy install --roles-path ./roles/ cloudalchemy.grafana

yum install python2-pip-8.1.2-14.el7.noarch
pip install --upgrade pip
pip install jmespath

firewall-cmd --permanent --add-port=3000/tcp --add-port=9090/tcp
firewall-cmd --reload


vagrant up

curl 'localhost:9090/metrics'
```

## **Полезное:**

