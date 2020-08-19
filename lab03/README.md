# **Домашнее задание №3: Файловые системы и LVM**

## **Задание:**
Работа с LVM
на имеющемся образе
/dev/mapper/VolGroup00-LogVol00 38G 738M 37G 2% /

- уменьшить том под / до 8G
- выделить том под /home
- выделить том под /var
- /var - сделать в mirror
- /home - сделать том для снэпшотов
- прописать монтирование в fstab
- попробовать с разными опциями и разными файловыми системами ( на выбор)
- сгенерить файлы в /home/
- снять снэпшот
- удалить часть файлов
- восстановится со снэпшота
- залоггировать работу можно с помощью утилиты script

* на нашей куче дисков попробовать поставить btrfs/zfs - с кешем, снэпшотами - разметить здесь каталог /opt

---

## **Выполнено:**

Протоколы работы по основному заданию и заданию с *](./script/)

1. Уменьшили том под / до 8G
```bash
yum install xfsdump -y
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
s/.img//g"` --force; done
```

В файле /boot/grub2/grub.cfg меняем rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root и перегружаемся:
```bash
sed -i 's!rd.lvm.lv=VolGroup00/LogVol00!rd.lvm.lv=vg_root/lv_root!' /boot/grub2/grub.cfg
exit
reboot
```

Заходим после перезагрузки:
```bash
lsblk
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
s/.img//g"` --force; done
exit
reboot
```

```bash
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root
pvremove /dev/sdb
```

2. Выделили том под /var, /var - сделали в mirror
```bash
pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
umount /mnt
mount /dev/vg_var/lv_var /var
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab

```

3. Выделили том под /home, /home - сделали том для снэпшотов, сгенерили файлы в /home/
- сняли снэпшот
- удалили часть файлов
- восстановились со снэпшота

```bash
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
touch /home/file{1..20}
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
lsblk
rm -f /home/file{11..20}
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home
```

**'*'**. Ставим btrfs - с кешем, снэпшотами - разметили здесь каталог /opt

```bash
pvcreate /dev/sdb
vgcreate vg_opt /dev/sdb
lvcreate -n lv_opt -l +100%FREE /dev/vg_opt
mkfs.btrfs /dev/vg_opt/lv_opt
mount /dev/vg_opt/lv_opt /opt
btrfs sub create /opt/volume
btrfs subvolume show /opt
btrfs subvolume list /opt/
touch /opt/volume/file{1..20}
btrfs sub snapshot /opt/volume /opt/volume-snap
btrfs subvolume list /opt/
rm -f /opt/volume/file{11..20}
cd /opt
btrfs sub delete volume
mv volume-snap volume
```


## **Полезное:**

- Sudo-rsync:
```Bash
vagrant plugin install vagrant-sudo-rsync
vagrant sudo-rsync :/vagrant/* ./script/
```
- История чата: [chat.txt](chat.txt)
- Ссылки: [links.md](links.md)
