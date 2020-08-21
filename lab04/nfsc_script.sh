#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install nfs-utils -y
systemctl enable {firewalld,rpcbind}
systemctl restart {firewalld,rpcbind}
echo '192.168.50.10:/home/upload /mnt         nfs     noauto,x-systemd.automount,rw,vers=3,proto=udp	0 0' >> /etc/fstab
mount /mnt

