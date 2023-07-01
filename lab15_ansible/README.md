## lab15_ansible
### Подготовить стенд на Vagrant. На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:

* необходимо использовать модуль yum:
```
[stas@vmalma0 lab15_ansible]$ ansible nginx -m yum -a "name=epel-release state=present" -b
nginx | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: epel-release-8-11.el8.noarch"
    ]
}

```
* конфигурационные файлы должны быть взяты из шаблона jinja2 с перемененными:
```
  # {{ ansible_managed }}
events {
    worker_connections 1024;
}
http {
    server {
        listen       {{ nginx_listen_port }} default_server;
        server_name  default_server;
        root         /usr/share/nginx/html;

        location / {
        }
    }
}

```

* должен быть использован notify для старта nginx после установки:
```
---
# handlers file for nginx
- name: restart nginx
  systemd:
    name: nginx
    state: restarted
    enabled: yes

- name: reload nginx
  systemd:
    name: nginx
    state: reloaded
```


* Предоставлен [Vagrantfile](./Vagrantfile) и готовый playbook/роль [playbook/play.yml](./playbooks/play.yml):
```
---
- name: NGINX | Install and configure NGINX
  hosts: nginx
  become: true
  roles:
    - epel
    - nginx
```
* Ход выполения:
```
[stas@vmalma0 lab15_ansible]$ ansible-playbook playbooks/play.yml 

PLAY [NGINX | Install and configure NGINX] *********************************************

TASK [Gathering Facts] *****************************************************************
ok: [nginx]

TASK [epel : NGINX | Install EPEL Repo package from standart repo] *********************
ok: [nginx]

TASK [nginx : NGINX | Install NGINX package from EPEL Repo] ****************************
changed: [nginx]

TASK [nginx : NGINX | Create NGINX config file from temlate] ***************************
changed: [nginx]

RUNNING HANDLER [nginx : restart nginx] ************************************************
changed: [nginx]

RUNNING HANDLER [nginx : reload nginx] *************************************************
changed: [nginx]

PLAY RECAP *****************************************************************************
nginx                      : ok=6    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```



* После запуска стенда nginx доступен на порту 8080:

```

[stas@vmalma0 lab15_ansible]$ curl -v 127.0.0.1:8080
*   Trying 127.0.0.1:8080...
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.76.1
> Accept: */*
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Server: nginx/1.14.1
< Date: Sat, 01 Jul 2023 12:45:02 GMT
< Content-Type: text/html
< Content-Length: 4057
< Last-Modified: Mon, 07 Oct 2019 21:16:24 GMT
< Connection: keep-alive
< ETag: "5d9bab28-fd9"
< Accept-Ranges: bytes
< 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
    <head>
        <title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>

```
* после установки nginx в режиме enabled в systemd:
```
[vagrant@nginxvm ~]$ systemctl status nginx.service 
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2023-07-01 12:43:50 UTC; 53min ago
  Process: 36162 ExecReload=/bin/kill -s HUP $MAINPID (code=exited, status=0/SUCCESS)
  Process: 35933 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 35931 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 35930 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 35935 (nginx)
    Tasks: 2 (limit: 2746)
   Memory: 2.3M
   CGroup: /system.slice/nginx.service
           ├─35935 nginx: master process /usr/sbin/nginx
           └─36163 nginx: worker process
```



* Лог выполнения:
[lab15_ansible.txt](lab15_ansible.txt)