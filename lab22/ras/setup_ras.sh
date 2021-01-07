#!/bin/bash

set -x
yum install -y epel-release
yum install -y openvpn easy-rsa policycoreutils-python
semanage port -a -t openvpn_port_t -p udp 1207
###########################################################
#Переходим в директорию /etc/openvpn/ и инициализируем pki#
###########################################################
cd /etc/openvpn/
echo 'yes' | /usr/share/easy-rsa/3/easyrsa init-pki

###########################################################
#Сгенерируем необходимые ключи и сертификаты длā сервера  #
###########################################################
echo 'rasvpn' | /usr/share/easy-rsa/3/easyrsa build-ca nopass
echo 'rasvpn' | /usr/share/easy-rsa/3/easyrsa gen-req server nopass
echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req server server
/usr/share/easy-rsa/3/easyrsa gen-dh > /dev/null 2>&1
openvpn --genkey --secret ta.key

echo 'iroute 192.168.11.0 255.255.255.0' > /etc/openvpn/client/client

######################################
#Сгенерируем сертификаты для клиента.#
######################################
echo 'client' | /usr/share/easy-rsa/3/easyrsa gen-req client nopass
echo 'yes' | /usr/share/easy-rsa/3/easyrsa sign-req client client

