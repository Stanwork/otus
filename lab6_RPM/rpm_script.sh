#!/bin/bash

yum update -y
yum install -y \
    redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc tree langpacks-en glibc-all-langpacks
sudo -i    
#create dir for packages
mkdir -p /root/packages
#download NGINX SRPM:
wget -P /root/packages https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm
#install nginx srpm
rpm -i /root/packages/nginx-1.*
tree ~
#download openssl src
wget -P /root/packages https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip
unzip /root/packages/OpenSSL* -d ~/packages
yum-builddep -y /root/rpmbuild/SPECS/nginx.spec
#add --with-openssl to nginx.spec
sed -i '/--with-debug/c  --with-openssl=/root/packages/openssl-OpenSSL_1_1_1-stable' /root/rpmbuild/SPECS/nginx.spec
#build RPM
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
#install RPM
yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
#start nginx
systemctl start nginx
systemctl enable nginx
#create repo
mkdir -p /usr/share/nginx/html/repo
cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
#init repo
createrepo /usr/share/nginx/html/repo/
#В location / в файле /etc/nginx/conf.d/default.conf добавим директиву autoindex on
sed -i '/index/a \\t autoindex on;' /etc/nginx/conf.d/default.conf
nginx -s reload
#add to yum.repos.d
cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
#install percona
yum install percona-orchestrator.x86_64 -y