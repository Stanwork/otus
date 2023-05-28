#!/bin/bash

#Prepare & install packages:
mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
yum install epel-release -y
yum install spawn-fcgi php php-cli mod_fcgid httpd -y

#Copy files:
cp /tmp/scripts/alert_add.sh /opt
cp /tmp/scripts/tail_add.sh /opt
cp /tmp/scripts/watchlog /etc/sysconfig
sudo cp /tmp/scripts/watchlog.service /etc/systemd/system
sudo cp -f /tmp/scripts/spawn-fcgi /etc/sysconfig/
sudo cp /tmp/scripts/spawn-fcgi.service /etc/systemd/system
sudo cp /tmp/scripts/first.conf /etc/httpd/conf
sudo cp /tmp/scripts/httpd-first /etc/sysconfig
sudo cp /tmp/scripts/httpd-second /etc/sysconfig
sudo cp '/tmp/scripts/httpd@first.service' /etc/systemd/system
sudo cp '/tmp/scripts/httpd@second.service' /etc/systemd/system
sudo cp /tmp/scripts/first.conf /etc/httpd/conf
sudo cp /tmp/scripts/second.conf /etc/httpd/conf
cp /tmp/scripts/watchlog.sh /opt
sudo cp /tmp/scripts/watchlog.timer /etc/systemd/system

#Make scripts executable:
chmod +x /opt/*.sh

#Add scripts in cron:
(sudo crontab -l | 2>/dev/null; echo "*/3 * * * * /opt/tail_add.sh"; echo "*/5 * * * * /opt/alert_add.sh") | crontab -

#Change TimeZone    
sudo timedatectl set-timezone Europe/Moscow

#Start services:
sudo systemctl start watchlog.timer
sudo systemctl start watchlog.service
sudo systemctl enable watchlog.timer
sudo systemctl start spawn-fcgi
sudo systemctl daemon-reload
sudo systemctl start httpd@first
sudo systemctl start httpd@second
