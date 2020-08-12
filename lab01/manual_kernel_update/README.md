#  Домашняя работа №1
Обновить ядро в базовой системе

Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
В материалах к занятию есть методичка, в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.
Для выполнения ДЗ со * и ** вам потребуется сборка ядра и модулей из исходников.
Критерии оценки: Основное ДЗ - в репозитории есть рабочий Vagrantfile с вашим образом.
ДЗ со звездочкой: Ядро собрано из исходников
ДЗ с **: В вашем образе нормально работают VirtualBox Shared Folders

---

Выполнено:

## **1.Установлено ПО**

- Vagrant v.2.2.9
```Bash
wget https://releases.hashicorp.com/vagrant/2.2.9/vagrant_2.2.9_x86_64.rpm
yum install vagrant_2.2.9_x86_64.rpm
```

- VirtualBox v.6.1.12: <https://www.virtualbox.org/wiki/Linux_Downloads>

- Packer v.1.6.1

```Bash
curl https://releases.hashicorp.com/packer/1.6.1/packer_1.6.1_linux_amd64.zip | \
sudo gzip -d > /usr/local/bin/packer && \
sudo chmod +x /usr/local/bin/packer
```

## **2.Обновление ядра из репозитория**

Подготовлен [Vagrantfile](Vagrantfile), обновляющий ядро 3.10.0-1127.el7.x86_64 ->  5.8.1-1.el7.elrepo.x86_64 из репозитория elrepo  