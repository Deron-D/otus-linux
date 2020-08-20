#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk \
redhat-lsb-core \
wget \
rpmdevtools \
rpm-build \
createrepo \
yum-utils \
gcc
cd /root
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
yum-builddep rpmbuild/SPECS/nginx.spec -y
wget -O rpmbuild/SPECS/nginx.spec https://raw.githubusercontent.com/Deron-D/otus-linux/master/lab05/nginx.spec
rpmbuild -bb rpmbuild/SPECS/nginx.spec
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
systemctl start nginx
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm \
-O /usr/share/nginx/html/repo/percona-release-0.1-6.noarch.rpm
createrepo /usr/share/nginx/html/repo/
wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/Deron-D/otus-linux/master/lab05/default.conf
nginx -t
nginx -s reload
echo '[otus]' > /etc/yum.repos.d/otus.repo
echo 'name=otus-linux' >> /etc/yum.repos.d/otus.repo
echo 'baseurl=http://localhost/repo' >> /etc/yum.repos.d/otus.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/otus.repo
echo 'enabled=1' >> /etc/yum.repos.d/otus.repo

