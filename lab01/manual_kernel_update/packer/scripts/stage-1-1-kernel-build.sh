#!/bin/bash

# Install elrepo
#yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# Install new kernel
#yum --enablerepo elrepo-kernel install kernel-ml -y
# Remove older kernels (Only for demo! Not Production!)
#rm -f /boot/*3.10*
# Update GRUB
#grub2-mkconfig -o /boot/grub2/grub.cfg
#grub2-set-default 0
#echo "Grub update done."
# Reboot VM
#shutdown -r now


yum install -y ncurses-devel make bc bison flex elfutils-libelf-devel openssl-devel grub2 wget perl bzip2 &&
yum install -y centos-release-scl-rh &&
yum install -y devtoolset-7-gcc-c++ &&
cd /opt/rh/devtoolset-7
. enable
cd /usr/src/ &&
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.8.1.tar.xz &&
tar -xf linux-5.8.1.tar.xz &&
rm -f linux-5.8.1.tar.xz &&
cd linux-5.8.1 &&
cp -v /boot/config-$(uname -r) .config &&
make olddefconfig &&
date && make -j8 &&
sleep 1m &&
date && make -j8 modules_install &&
sleep 1m &&
date && make install &&
date

# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10* &&
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg &&
grub2-set-default 0 &&
echo "Grub update done."
# Reboot VM
shutdown -r now
