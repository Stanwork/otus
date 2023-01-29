#!/bin/bash

yum install -y nfs-utils
#firewalld settings:
systemctl enable firewalld --now
#mount nfs /mnt
echo "192.168.56.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
systemctl daemon-reload
systemctl restart remote-fs.target
