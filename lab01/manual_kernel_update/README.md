#  Домашняя работа №1
Обновить ядро в базовой системе

Цель: Студент получит навыки работы с Git, Vagrant, Packer и публикацией готовых образов в Vagrant Cloud.
В материалах к занятию есть методичка, в которой описана процедура обновления ядра из репозитория. По данной методичке требуется выполнить необходимые действия. Полученный в ходе выполнения ДЗ Vagrantfile должен быть залит в ваш репозиторий. Для проверки ДЗ необходимо прислать ссылку на него.
Для выполнения ДЗ со * и ** вам потребуется сборка ядра и модулей из исходников.
Критерии оценки: Основное ДЗ - в репозитории есть рабочий Vagrantfile с вашим образом.
ДЗ со звездочкой: Ядро собрано из исходников
ДЗ с **: В вашем образе нормально работают VirtualBox Shared Folders

---

## Выполнено:

## **1.Установлено ПО**

- Vagrant v.2.2.15
```Bash
wget https://releases.hashicorp.com/vagrant/2.2.15/vagrant_2.2.15_x86_64.rpm 
sudo dnf localinstall vagrant_2.2.15_x86_64.rpm
```

- VirtualBox v.6.1.12: <https://www.virtualbox.org/wiki/Linux_Downloads>
```Bash
wget https://download.virtualbox.org/virtualbox/6.1.18/VirtualBox-6.1-6.1.18_142142_el8-1.x86_64.rpm
sudo dnf localinstall VirtualBox-6.1-6.1.18_142142_el8-1.x86_64.rpm
```
- Packer v.1.7.2
```Bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install packer
```

## **2.Обновление ядра из репозитория**

Подготовлен [Vagrantfile](Vagrantfile), обновляющий ядро 3.10.0-1127.el7.x86_64 ->  5.8.1-1.el7.elrepo.x86_64 из репозитория elrepo


## **3.Создание с помощью утилиты packer Vagrant box с собранным из исходников ядром и поддержкой VirtualBox Shared Folders**

- Packer build
```Bash
packer build centos-kernel-build.json
```

- Импорт созданного образа в Vagrant и проверка результатов сборки, включая поддержку VirtualBox Shared Folders:
```Bash
vagrant box add --name centos-7-9 centos-7.9.2009-kernel-5.4.109-x86_64-Minimal.box
vagrant box list
Deron-D/centos-7-9 (virtualbox, 1.0)
centos-7-9         (virtualbox, 0)
centos/7           (virtualbox, 2004.01)
vagrant up
vagrant ssh
[vagrant@localhost ~]$ uname -r
5.4.109
[vagrant@localhost ~]$ ls /vagrant/
centos-7.9.2009-kernel-5.4.109-x86_64-Minimal.box  centos.json  centos-kernel-build.json  http  packer_cache  scripts  Vagrantfile
```

- Выгрузка полученного образа centos-7.9.2009-kernel-5.4.109-x86_64-Minimal.box в [Vagrant Cloud](https://app.vagrantup.com/Deron-D/boxes/centos-7-9)
```Bash
vagrant cloud publish --release Deron-D/centos-7-9 1.0 virtualbox centos-7.9.2009-kernel-5.4.109-x86_64-Minimal.box
```

### Полезное

- Structure of monolithic kernel, microkernel and hybrid kernel-based operating systems <https://ru.wikipedia.org/wiki/%D0%93%D0%B8%D0%B1%D1%80%D0%B8%D0%B4%D0%BD%D0%BE%D0%B5_%D1%8F%D0%B4%D1%80%D0%BE#/media/%D0%A4%D0%B0%D0%B9%D0%BB:OS-structure2.svg>
- Evolution of the x86 context switch in Linux – MaiZure's Projects <https://www.maizure.org/projects/evolution_x86_context_switch_linux/#Linux24> 
- Ядро Linux и его функции — /dev/mem <https://pustovoi.ru/2010/1033>
