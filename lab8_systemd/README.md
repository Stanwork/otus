## Инициализация системы. Systemd.

### 1 Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).  

Создаём конфигурацонный файл  для сервиса [watchlog](./scripts/watchlog):

```
cat watchlog
# Configuration file for my watchlog service
# Place it to /etc/sysconfig
# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log

```

Создаём файлы для заполнения лога [alert_add.sh](./scripts/alert_add.sh):

```
cat alert_add.sh 
#!/bin/bash
/bin/echo `/bin/date "+%b %d %T"` ALERT >> /var/log/watchlog.log

```
[tail_add.sh](./scripts/tail_add.sh)
```
cat tail_add.sh
#!/bin/bash
/bin/tail /var/log/messages >> /var/log/watchlog.log

```

Создаём скрипт записи в лог [watchlog.sh](./scripts/watchlog.sh):

```
cat watchlog.sh
#!/bin/bash
WORD=$1
LOG=$2
DATE=`/bin/date`
if grep $WORD $LOG &> /dev/null; then
    logger "$DATE: I found word, Master!"
	exit 0
else
    exit 0
fi
```

Создаём unit-файл сервиса [watchlog.service](./scripts/watchlog.service):

```
cat > /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```


Создаём unit-файл таймера [watchlog.timer](./scripts/watchlog.timer):

```
cat > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target

```

Добавляем в [Vagrantfile](./Vagrantfile):

```
box.vm.provision "file", source: "./scripts/", destination: "/tmp/"
box1.vm.provision "shell", path: "./scripts/provision.sh"
```
[provision.sh](./scripts/provision.sh) - скрипт настройки ВМ, конфигурирования сервисов и копирования конфигов

Проверяем:

```
[root@labsystemd vagrant]# tail /var/log/messages
May 28 10:28:04 localhost systemd: Started My watchlog service.
May 28 10:28:34 localhost systemd: Starting My watchlog service...
May 28 10:28:34 localhost root: Sun May 28 13:28:34 MSK 2023: I found word, Master!
May 28 10:28:34 localhost systemd: Started My watchlog service.
May 28 10:29:04 localhost systemd: Starting My watchlog service...
May 28 10:29:04 localhost root: Sun May 28 13:29:04 MSK 2023: I found word, Master!
May 28 10:29:04 localhost systemd: Started My watchlog service.
May 28 10:29:34 localhost systemd: Starting My watchlog service...
```

### 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).  

Создаём файл [spawn-fcgi.service](./scripts/spawn-fcgi.service):

```
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target
```

Создаём отредактированный файл [spawn-fcgi](./scripts/spawn-fcgi):

```
cat spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

```

Проверяем:

```
[root@labsystemd vagrant]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-05-28 13:03:59 MSK; 29min ago
 Main PID: 4520 (php-cgi)

```


### 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.  

Для запуска нескольких экземпляров сервиса используется шаблон в конфигурации файла окружения (/usr/lib/systemd/system/httpd.service ):  
Копируем файл из /usr/lib/systemd/system/, cp /usr/lib/systemd/system/httpd.service /etc/systemd/system, далее переименовываем mv /etc/systemd/system/httpd.service /etc/systemd/system/httpd@.service и приводим к виду:
[httpd@first.service ](./scripts/httpd%40first.service)
```
cat httpd@first.service 
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
# We want systemd to give httpd some time to finish gracefully, but still want
# it to kill httpd after TimeoutStopSec if something went wrong during the
# graceful stop. Normally, Systemd sends SIGTERM signal right after the
# ExecStop, which would kill httpd. We are sending useless SIGCONT here to give
# httpd time to finish.
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
[httpd@second.service](./scripts/httpd%40second.service)
```
cat httpd@second.service 
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
# We want systemd to give httpd some time to finish gracefully, but still want
# it to kill httpd after TimeoutStopSec if something went wrong during the
# graceful stop. Normally, Systemd sends SIGTERM signal right after the
# ExecStop, which would kill httpd. We are sending useless SIGCONT here to give
# httpd time to finish.
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

В файлах окружения задается опция для запуска веб-сервера с конфигурационным файлом:
[httpd-first](./scripts/httpd-first)
```
# /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
```
[httpd-second](./scripts/httpd-second)
```
# /etc/sysconfig/httpd-second
OPTIONS=-f conf/second.conf
```

В директорию с конфигами httpd, кладём 2 конфига first.conf и second.conf:

```
grep -P "^PidFile|^Listen" first.conf 
PidFile "/var/run/httpd-first.pid"
Listen 80
```

```
grep -P "^PidFile|^Listen" second.conf 
PidFile "/var/run/httpd-second.pid"
Listen 8080
```

Запускаем [Vagrantfile](./Vagrantfile) и проверяем статусы httpd сервисов:

```
[root@labsystemd vagrant]# systemctl status httpd@first.service
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@first.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-05-28 13:03:59 MSK; 33min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4571 (httpd)
   Status: "Total requests: 13; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─4571 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4572 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4573 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4574 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4575 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4576 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4577 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─4685 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─4691 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

May 28 13:03:59 labsystemd systemd[1]: Starting The Apache HTTP Server...
May 28 13:03:59 labsystemd httpd[4571]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
May 28 13:03:59 labsystemd systemd[1]: Started The Apache HTTP Server.

```
 
```
[root@labsystemd vagrant]# systemctl status httpd@second.service 
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@second.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-05-28 13:03:59 MSK; 34min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 4581 (httpd)

```
Видим, что порты 80 и 8080 слушаются:

```
[root@labsystemd vagrant]# ss -tnulp | grep httpd
tcp    LISTEN     0      128    [::]:8080               [::]:*                   users:(("httpd",pid=4696,fd=4),("httpd",pid=4695,fd=4),("httpd",pid=4694,fd=4),("httpd",pid=4587,fd=4),("httpd",pid=4586,fd=4),("httpd",pid=4585,fd=4),("httpd",pid=4584,fd=4),("httpd",pid=4583,fd=4),("httpd",pid=4582,fd=4),("httpd",pid=4581,fd=4))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=4691,fd=4),("httpd",pid=4685,fd=4),("httpd",pid=4577,fd=4),("httpd",pid=4576,fd=4),("httpd",pid=4575,fd=4),("httpd",pid=4574,fd=4),("httpd",pid=4573,fd=4),("httpd",pid=4572,fd=4),("httpd",pid=4571,fd=4))

```
```
[root@labsystemd vagrant]# curl -I http://localhost:8080
HTTP/1.1 403 Forbidden
Date: Sun, 28 May 2023 11:10:19 GMT
Server: Apache/2.4.6 (CentOS) mod_fcgid/2.3.9 PHP/5.4.16
Last-Modified: Thu, 16 Oct 2014 13:20:58 GMT
ETag: "1321-5058a1e728280"
Accept-Ranges: bytes
Content-Length: 4897
Content-Type: text/html; charset=UTF-8
```