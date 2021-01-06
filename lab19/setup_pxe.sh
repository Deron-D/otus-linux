#!/bin/bash

INITRD_URL=http://mirror.nsc.liu.se/centos-store/8.2.2004/BaseOS/x86_64/os/images/pxeboot/initrd.img
VMLINUZ_URL=http://mirror.nsc.liu.se/centos-store/8.2.2004/BaseOS/x86_64/os/images/pxeboot/vmlinuz
BOOTISO_URL=http://mirror.nsc.liu.se/centos-store/8.2.2004/isos/x86_64/CentOS-8.2.2004-x86_64-minimal.iso
BOOTISO_NAME=CentOS-8.2.2004-x86_64-minimal.iso

echo Install PXE server
yum -y install epel-release

yum -y install dhcp-server
yum -y install tftp-server
yum -y install nfs-utils
yum -y install httpd
#firewall-cmd --add-service=tftp
# disable selinux or permissive
setenforce 0
# 

cat >/etc/dhcp/dhcpd.conf <<EOF
option space pxelinux;
option pxelinux.magic code 208 = string;
option pxelinux.configfile code 209 = text;
option pxelinux.pathprefix code 210 = text;
option pxelinux.reboottime code 211 = unsigned integer 32;
option architecture-type code 93 = unsigned integer 16;
subnet 10.0.0.0 netmask 255.255.255.0 {
	#option routers 10.0.0.254;
	range 10.0.0.100 10.0.0.120;
	class "pxeclients" {
	  match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
	  next-server 10.0.0.20;
	  if option architecture-type = 00:07 {
	    filename "uefi/shim.efi";
	    } else {
	    filename "pxelinux/pxelinux.0";
	  }
	}
}
EOF
systemctl start dhcpd

systemctl start tftp.service
yum -y install syslinux-tftpboot.noarch
mkdir /var/lib/tftpboot/pxelinux
cp /tftpboot/pxelinux.0 /var/lib/tftpboot/pxelinux
cp /tftpboot/libutil.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/menu.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/libmenu.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/ldlinux.c32 /var/lib/tftpboot/pxelinux
cp /tftpboot/vesamenu.c32 /var/lib/tftpboot/pxelinux

mkdir /var/lib/tftpboot/pxelinux/pxelinux.cfg

cat >/var/lib/tftpboot/pxelinux/pxelinux.cfg/default <<EOF
default menu
prompt 0
timeout 600
MENU TITLE Demo PXE setup
LABEL linux
  menu label ^Install system
  menu default
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=enp0s3:dhcp inst.repo=http://10.0.0.20/centos8-install
LABEL linux-auto
  menu label ^Auto install system
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=enp0s3:dhcp inst.ks=http://10.0.0.20/cfg/ks.cfg inst.repo=http://10.0.0.20/centos8-install
LABEL vesa
  menu label Install system with ^basic video driver
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img ip=enp0s3:dhcp inst.xdriver=vesa nomodeset inst.repo=http://10.0.0.20/centos8-install
LABEL rescue
  menu label ^Rescue installed system
  kernel images/CentOS-8.2/vmlinuz
  append initrd=images/CentOS-8.2/initrd.img rescue
LABEL local
  menu label Boot from ^local drive
  localboot 0xffff
EOF

mkdir -p /var/lib/tftpboot/pxelinux/images/CentOS-8.2/
curl -O $INITRD_URL 
curl -O $VMLINUZ_URL
cp {vmlinuz,initrd.img} /var/lib/tftpboot/pxelinux/images/CentOS-8.2/


# Setup HTTP auto install
# 

curl -O $BOOTISO_URL
mkdir /mnt/centos8-install
mount -t iso9660 $BOOTISO_NAME /mnt/centos8-install
#cp -r /mnt/centos8-install/ /var/www/html/

cat > /etc/httpd/conf.d/pxeboot.conf <<EOF_pxeboot_conf
# create new
Alias /centos8-install /mnt/centos8-install
<Directory /mnt/centos8-install>
    Options Indexes FollowSymLinks
    # access permission
    Require all granted
</Directory>
EOF_pxeboot_conf

systemctl enable httpd
systemctl restart httpd

autoinstall(){
  # to speedup replace URL with closest mirror
  #curl -O http://ftp.mgts.by/pub/CentOS/8.2.2004/isos/x86_64/CentOS-8.2.2004-x86_64-minimal.iso
  #mkdir /mnt/centos8-autoinstall
  #mount -t iso9660 CentOS-8.2.2004-x86_64-minimal.iso /mnt/centos8-autoinstall
  #echo '/mnt/centos8-autoinstall *(ro)' >> /etc/exports
  mkdir /var/www/html/cfg

cat >  /var/www/html/cfg/ks.cfg <<EOF
#version=RHEL8
ignoredisk --only-use=sda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda
# Use graphical install
graphical
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp0s8 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain
repo --name="Minimal" --baseurl=http://10.0.0.20/centos8-install/Minimal
# Use network installation
url --url="http://10.0.0.20/centos8-install"
# Root password
rootpw --iscrypted $6$SUrwb45ZDdFsoSsy$xBoJyVtmxg0w1LENyAumny9RobWCFue8y2MkiCO7oqLPAVUNA/Q1hVCU.xkVidzmIqxIvUNDEQTYCCMx/UhPm.
# Run the Setup Agent on first boot
firstboot --enable
# Do not configure the X Window System
skipx
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc

%packages
@^server-product-environment
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
EOF

systemctl restart httpd
}
# uncomment to enable automatic installation
autoinstall
