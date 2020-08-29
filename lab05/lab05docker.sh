#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
echo "Install required tools"
yum install -y docker
systemctl start docker
echo "================================"
echo "Add repository from lab05 to YUM"
echo "================================"
echo '[lab05repo]' > /etc/yum.repos.d/lab05.repo
echo 'name=Lab05 NGINX Package Repository' >> /etc/yum.repos.d/lab05.repo
echo 'baseurl=http://192.168.11.101/repo' >> /etc/yum.repos.d/lab05.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/lab05.repo
echo 'enabled=1' >> /etc/yum.repos.d/lab05.repo
yumdownloader nginx
curl -o Dockerfile https://raw.githubusercontent.com/Deron-D/otus-linux/master/lab05/Dockerfile
docker build -t deron73/my-nginx-ssl-image:1.1 .



