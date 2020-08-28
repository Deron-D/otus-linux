#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
echo "Install required tools"
yum install -y mdadm smartmontools hdparm gdisk wget createrepo rpmdevtools rpm-build createrepo gcc redhat-lsb-core yum-utils
cd /root
echo "========================"
echo "Download NGINX SourceRPM"
echo "========================"
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-1.el7.ngx.src.rpm
echo "======================================"
echo "Install the package to /root directory"
echo "======================================"
rpm -ihv nginx-1.18.0-1.el7.ngx.src.rpm
echo "======================================"
echo "Download latest OpenSSL library source"
echo "======================================"
wget https://www.openssl.org/source/latest.tar.gz
tar -xvf latest.tar.gz
echo "==========================="
echo "Install dependency packages"
echo "==========================="
yum-builddep rpmbuild/SPECS/nginx.spec -y
echo "============================================"
echo "Get my SPEC file with support latest OpenSSL"
echo "============================================"
wget -O rpmbuild/SPECS/nginx.spec https://raw.githubusercontent.com/Deron-D/otus-linux/master/lab05/nginx.spec
echo "============="
echo "Build own RPM"
echo "============="
rpmbuild -bb rpmbuild/SPECS/nginx.spec
echo "================================================"
echo "Install the own RPM package from local directory"
echo "================================================"
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm
echo "==================="
echo "Start nginx service"
echo "==================="
systemctl start nginx
mkdir /usr/share/nginx/html/repo
echo "========================================="
echo "Copy own rpm to the future repo directory"
echo "========================================="
cp /root/rpmbuild/RPMS/x86_64/nginx-1.18.0-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/
echo "======================="
echo "Create local repository"
echo "======================="
createrepo /usr/share/nginx/html/repo/
echo "============================================="
echo "Get own custom nginx conf with: autoindex on;"
echo "============================================="
wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/Deron-D/otus-linux/master/lab05/default.conf
echo "======================="
echo "Apply new conf to nginx"
echo "======================="
nginx -s reload
echo "==============================="
echo "Add local own repository to YUM"
echo "==============================="
echo '[lab05repo]' > /etc/yum.repos.d/lab05.repo
echo 'name=Lab05 NGINX Package Repository' >> /etc/yum.repos.d/lab05.repo
echo 'baseurl=http://localhost/repo' >> /etc/yum.repos.d/lab05.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/lab05.repo
echo 'enabled=1' >> /etc/yum.repos.d/lab05.repo




