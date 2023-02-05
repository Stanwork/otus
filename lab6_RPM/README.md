Работа с  RPM
===============
 
**1. Создается RPM пакет NGINX с поддержкой openssl**

* Запуск сборки:
```
vagrant up
```
- скрипт сборки из [SRPM пакета NGINX](https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm) : [rpm_script.sh](https://github.com/Stanwork/otus_labs/blob/main/lab6_RPM/rpm_script.sh)

- результат сборки - работающий nginx:
```
[root@rpm-test ~]# systemctl status nginx
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-02-05 13:56:42 UTC; 42min ago
     Docs: http://nginx.org/en/docs/
  Process: 63073 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 63074 (nginx)
    Tasks: 3 (limit: 4951)
   Memory: 3.0M
   CGroup: /system.slice/nginx.service
           ├─63074 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           ├─63101 nginx: worker process
           └─63103 nginx: worker process

фев 05 13:56:42 rpm-test systemd[1]: Starting nginx - high performance web server...
фев 05 13:56:42 rpm-test systemd[1]: Started nginx - high performance web server.
```

- лог сборки: [vagrant_up.txt](https://github.com/Stanwork/otus_labs/blob/main/lab6_RPM/vagrant_up.txt)

**2. Создается репозиторий otus с размещением собранного ранее RPM NGINX**

* RPM для установки репозитория [Percona-Server](https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm)

* проверка репозитория:
```
[root@rpm-test ~]# yum repolist enabled | grep otus
otus                  otus-linux
[root@rpm-test ~]# yum list | grep otus
otus-linux                                      2.9 MB/s | 3.0 kB     00:00    
percona-orchestrator.x86_64                                       2:3.2.6-2.el8                                          @otus        
```
