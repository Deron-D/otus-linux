# **Домашнее задание №6: Загрузка системы**

## **Задание:**
Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd

4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m
Критерии оценки: Описать действия, описать разницу между методами получения шелла в процессе загрузки.
Где получится - используем script, где не получается - словами или копипастой описываем действия.

---

## **Выполнено:**

### 1. Попадаем в систему без пароля несколькими способами:

#### Способ 1. init=/bin/sh
В конце строки начинающейся с linux16 добавляем init=/bin/sh (т.е. сообщаем ядру запустить /bin/sh как первый процесс с PID=1)и нажимаем сtrl-x для загрузки в систему.

![Screen 1.1](./screens/1.1.png)
![Screen 1.2](./screens/1.2.png)
![Screen 1.3](./screens/1.3.png)

Перемонтируем корневую систему в режиме Read-Write с проверкой
```bash
    mount -o remount,rw /
    mount | grep root
```

#### Способ 2. Через initrd, rd.break.

rd.break - даем инструкцию initrd запустить emergency mode и sh перед pivot_root()

![Screen 2.1](./screens/2.1.png)

Попадаем в emergency mode

![Screen 2.2](./screens/2.2.png)

Выполняем:
```
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
touch /.autorelabel
```
![Screen 2.3](./screens/2.3.png)

Создание .autorelabel сообщает SELinux о необходимости запуска в initrd процесса restorecon(восстановления контекста) при последующей перезагрузке.

#### Способ 3. rw init=/sysroot/bin/sh

![Screen 3.1](./screens/3.1.png)

Наблюдаем в журнале /run/initramfs/rdsosreport.txt, что initrd не удалось запустить init=/sysroot/sysroot/bin/sh и система справедливо решила провалиться в Emergency Mode

![Screen 3.2](./screens/3.2.png)
![Screen 3.3](./screens/3.3.png)

### 2. Установливаем систему с LVM, после чего переименовываем VG

Смотрим текущее состояние системы и переименовываем Volume Group:
![Screen 22.1](./screens/22.1.png)

Правим [/etc/fstab](conf/fstab), [/etc/default/grub](conf/grub), [/boot/grub2/grub.cfg](conf/grub.cfg)

Пересоздаем initrd image, чтобы он знал новое название Volume Group
```bash
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```
![Screen 22.2](./screens/22.2.png)

Перегружаемся и проверяем:

![Screen 22.3](./screens/22.3.png)


## **Полезное:**

