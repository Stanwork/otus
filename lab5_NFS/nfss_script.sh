#!/bin/bash

yum install -y nfs-utils
#firewalld settings:
systemctl enable firewalld --now
firewall-cmd --add-service="nfs3" \
             --add-service="rpc-bind" \
             --add-service="mountd" \
             --permanent
firewall-cmd --reload

# Enable NFS-server:
systemctl enable nfs --now

#mkdir for export
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

#/etc/exports
cat << EOF > /etc/exports
/srv/share 192.168.56.11/32(rw,sync,root_squash)
EOF
#export dir
exportfs -r
