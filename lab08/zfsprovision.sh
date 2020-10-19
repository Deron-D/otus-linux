#!/bin/bash

mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y yum-utils wget
yum -y install http://download.zfsonlinux.org/epel/zfs-release.el7_4.noarch.rpm
gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
yum-config-manager --enable zfs-kmod
yum-config-manager --disable zfs
yum repolist | grep zfs && echo ZFS repo enabled
yum install -y zfs
/sbin/modprobe zfs
chmod +x /vagrant/download_gdrive
