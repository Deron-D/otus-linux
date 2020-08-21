#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
#yum install -y 
mkdir /home/upload
chmod -R 777 /home/upload
chown -R nfsnobody:nfsnobody /home/upload/
systemctl enable {nfs,rpcbind,nfslock,firewalld}
systemctl restart {nfs,firewalld}
echo '/home/upload 192.168.50.11(rw,async,all_squash,no_subtree_check)' > /etc/exports
exportfs -r
firewall-cmd --permanent --add-service=nfs3
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
