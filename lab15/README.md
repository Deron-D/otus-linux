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

task path: /root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/tasks/configure.yml:52
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/tasks/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/tasks/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/prometheus/targets"
[WARNING]: Unable to find 'prometheus/targets' in expected paths (use -vvvvv to see paths)
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/tasks/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/roles/cloudalchemy.prometheus/tasks/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/files/prometheus/targets"
looking for "prometheus/targets" at "/root/otus/otus-linux/lab15/prometheus/targets"

