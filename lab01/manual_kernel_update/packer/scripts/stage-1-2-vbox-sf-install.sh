#!/bin/bash


# Download VBoxGuestAdditions iso
curl https://download.virtualbox.org/virtualbox/6.1.18/VBoxGuestAdditions_6.1.18.iso -o /tmp/VBoxGuestAdditions_6.1.18.iso
# mount VBoxGuestAdditions iso
mount /tmp/VBoxGuestAdditions_6.1.18.iso /mnt -o loop
# install VBoxGuestAdditions
/mnt/VBoxLinuxAdditions.run
# umount VBoxGuestAdditions iso
umount /mnt
# remove VBoxGuestAdditions iso
rm -f /tmp/VBoxGuestAdditions_6.1.18.iso
