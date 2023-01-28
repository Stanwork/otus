Работа с  ZFS
===============

* ВМ AlmaLinux9 (Vagrant) c 8 доп. дисками sata{1..8}.vdi


            (1..8).each do |i|
                box1.vm.disk :disk, size: "512MB", name: "sata#{i}"
            end

* установка и настройка ZFS ( setup_zfs.sh )

* Запуск сборки: VAGRANT_EXPERIMENTAL=disks vagrant up
- лог сборки: [vagrant_up.txt](https://github.com/Stanwork/otus_labs/blob/main/zfs_loop/vagrant_up.txt)

1. Определение алгоритма с наилучшим сжатием

```
[root@vmzfs ~]# zfs get all | grep compressratio | grep -v ref
otus1            compressratio         1.35x                  -
otus2            compressratio         1.61x                  -
otus3            compressratio         2.46x                  -
otus4            compressratio         1.01x                  -
```

  * лог с помощью script записан в [zfs_1.txt](https://github.com/Stanwork/otus_labs/blob/main/zfs_loop/zfs_1.txt)
2. Определение настроек пула
```
[root@vmzfs ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  347M   -
[root@vmzfs ~]# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default
[root@vmzfs ~]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
[root@vmzfs ~]# zfs get compression otus
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
[root@vmzfs ~]# zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
  * лог с помощью script записан в [zfs_2.txt](https://github.com/Stanwork/otus_labs/blob/main/zfs_loop/zfs_2.txt)
3. Работа со снапшотом, поиск сообщения от преподавателя
```
[root@vmzfs ~]# cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```
  * лог с помощью script записан в [zfs_3.txt](https://github.com/Stanwork/otus_labs/blob/main/zfs_loop/zfs_3.txt)