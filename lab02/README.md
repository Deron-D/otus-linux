# **Домашнее задание №2: работа с mdadm**

## **Задание:**
- добавить в Vagrantfile еще дисков
- собрать R0/R5/R10 на выбор
- прописать собранный рейд в конф, чтобы рейд собирался при загрузке
- сломать/починить raid
- создать GPT раздел и 5 партиций и смонтировать их на диск.

В качестве проверки принимается - измененный Vagrantfile, скрипт для
создания рейда, конф для автосборки рейда при загрузке.


* Доп. задание - Vagrantfile, который сразу собирает систему с подключенным
рейдом

---

## **Выполнено:**

1. Добавлен в Vagrantfile еще 1 диск в секцию  :disks => {...}
```ruby
 :sata5 => {
         :dfile => './sata5.vdi',
         :size => 250, # Megabytes
         :port => 5
 }
```

2. Собран R10 с 1 hot spare
```bash
sudo -s
lsblk
lsscsi
lshw -short | grep disk
fdisk -l
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
mdadm --create --verbose /dev/md0 --level 10 --raid-devices=4 /dev/sd{b,c,d,e} --spare-devices=1 /dev/sdf
```
3. Прописан собранный рейд в конф, чтобы рейд собирался при загрузке:
```bash
mkdir /etc/mdadm
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | tee /etc/mdadm/mdadm.conf
```

4. Сломали/починили raid (1 диск в raid и hot spare)
```bash
mdadm /dev/md0 --fail /dev/sdd# "ломаем" обычный диск
cat /proc/mdstat
mdadm -D /dev/md0# видим, что включается hot spare
mdadm /dev/md0 --remove /dev/sdd
mdadm /dev/md0 --add /dev/sdd
cat /proc/mdstat
mdadm -D /dev/md0

mdadm /dev/md0 --fail /dev/sdf# "ломаем" диск hot spare
cat /proc/mdstat
mdadm -D /dev/md0
mdadm /dev/md0 --remove /dev/sdf
mdadm /dev/md0 --add /dev/sdf
cat /proc/mdstat
mdadm -D /dev/md0
```

5. Создан GPT раздел и 5 партиций. Смонтировали их на ФС с одновременной модификацей /etc/fstab
```bash
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; echo UUID=$(blkid -o value -s UUID /dev/md0p$i) /raid/part$i ext4 defaults 0 2 >> /etc/fstab; $
```

6. Добавлен в [Vagrantfile](Vagrantfile) в секцию  box.vm.provision скрипт, который сразу собирает систему с подключенным рейдом
`````ruby
 box.vm.provision "shell", inline: <<-SHELL
              mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
              mdadm --create --verbose /dev/md0 --level 10 --raid-devices=4 /dev/sd{b,c,d,e} --spare-devices=1 /dev/sdf
              mkdir /etc/mdadm
              mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | tee /etc/mdadm/mdadm.conf
              parted -s /dev/md0 mklabel gpt
              parted /dev/md0 mkpart primary ext4 0% 20%
              parted /dev/md0 mkpart primary ext4 20% 40%
              parted /dev/md0 mkpart primary ext4 40% 60%
              parted /dev/md0 mkpart primary ext4 60% 80%
              parted /dev/md0 mkpart primary ext4 80% 100%
              for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
              mkdir -p /raid/part{1,2,3,4,5}
              for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; echo UUID=$(blkid -o value -s UUID /dev/md0p$i) /raid/part$i ext4 defaults 0 2 >$
          SHELL
```

