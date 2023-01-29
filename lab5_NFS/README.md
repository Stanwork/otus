Работа с  NFS
===============

* Создаются 2 ВМ CentOS 7 (Vagrant)
-- nfss - NFS-сервер 192.168.56.10 (настройка скриптом [nfss_script.sh]())

-- nfsc - NFS-клиент 192.168.56.11 (настройка скриптом [nfsc_script.sh]())

* Запуск сборки:
```
vagrant up
```
- лог сборки: [vagrant_up.txt](https://github.com/Stanwork/otus_labs/blob/main/lab5_NFS/vagrant_up.txt)

* На сервере подготовлена и экспортирована директория /srv/share
--- проверка экспортов:
```
[root@nfss upload]# exportfs -s
/srv/share  192.168.56.11/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```
--- проверка работы RPC:
```
[root@nfss upload]# showmount -a
All mount points on nfss:
192.168.56.11:/srv/share
```
- файлы в /srv/share/upload:
```
[root@nfss /]# tree /srv/
/srv/
└── share
    └── upload
        ├── check_file
        ├── client_file
        └── final_check

2 directories, 3 files
```

* На клиенте экспортированная директория автоматически монтируется в /mnt с использованием NFSv3 по UDP

--- проверка работы RPC:
```
[root@nfsc upload]# showmount -a 192.168.56.10
All mount points on 192.168.56.10:
192.168.56.11:/srv/share
```
--- проверка статуса монтирования:
```
[root@nfsc upload]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=35,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=49408)
192.168.56.10:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.10)
```
--- файлы созданные для проверки:
```
[root@nfsc mnt]# tree /mnt
/mnt
└── upload
    ├── check_file
    ├── client_file
    └── final_check

1 directory, 3 files
```