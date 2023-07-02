## lab18_docker
### Написать Dockerfile на базе nginx, который будет содержать две статичные web-страницы на разных портах (80 и 3000).
-  Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам localhost:80 и localhost:3000
-  Добавить 2 вольюма. Один для логов приложения, другой для web-страниц.

-----------------------------------------------------------------------------------------------------------------------

* [Dockerfile](./Dockerfile):
```
FROM nginx:stable

#conf for logs in /log/nginx
COPY nginx.conf /etc/nginx/

#conf for :3000
COPY nginx_3000.conf /etc/nginx/conf.d/

#content:
COPY ./html/ /usr/share/nginx/html/
```

* Сборка образа:
```
[root@vmalma0 lab18_docker]# docker build -t nginx-3000 .
[+] Building 5.0s (9/9) FINISHED                                                                                                                                                                                   
 => [internal] load build definition from Dockerfile                                                                                                                                                          0.8s
 => => transferring dockerfile: 280B                                                                                                                                                                          0.0s
 => [internal] load .dockerignore                                                                                                                                                                             0.6s
 => => transferring context: 2B                                                                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/nginx:stable                                                                                                                                               2.2s
 => [1/4] FROM docker.io/library/nginx:stable@sha256:a8281ce42034b078dc7d88a5bfe6d25d75956aad9abba75150798b90fa3d1010                                                                                         0.0s
 => [internal] load build context                                                                                                                                                                             0.4s
 => => transferring context: 2.13kB                                                                                                                                                                           0.0s
 => CACHED [2/4] COPY nginx.conf /etc/nginx/                                                                                                                                                                  0.0s
 => CACHED [3/4] COPY nginx_3000.conf /etc/nginx/conf.d/                                                                                                                                                      0.0s
 => [4/4] COPY ./html/ /usr/share/nginx/html/                                                                                                                                                                 0.4s
 => exporting to image                                                                                                                                                                                        0.4s
 => => exporting layers                                                                                                                                                                                       0.3s
 => => writing image sha256:fad9da25dad16493613eead3db79db47975dad136729876f8ac51b1d3d542fce                                                                                                                  0.0s
 => => naming to docker.io/library/nginx-3000                                                                                                                                                                 0.0s
[root@vmalma0 lab18_docker]# docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
nginx-3000   latest    fad9da25dad1   8 seconds ago   142MB
```

* Запуск контейнера с пробросом портов и вольюмов для хранения html и логов:
```
[root@vmalma0 lab18_docker]# docker run --rm --name mynginx -p 80:80 -p 3000:3000 -v nginx_html:/usr/share/nginx/html -v nginx_logs:/log/nginx -d nginx-3000
5c5af0a49176b9da1675c6210e49a7c3edb4ac8356a3290a930d60bd40750fdb
[root@vmalma0 lab18_docker]# docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS                                                                          NAMES
5c5af0a49176   nginx-3000   "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   mynginx
```

* Доступность по портам 80 и 3000:
```
[root@vmalma0 lab18_docker]# curl localhost
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>lab18_docker_nginx:80</title>
</head>
<body>
  <p>lab18_docker by stanwork43@gmail.com</p>
  <h1>Nginx on :80</h1>	  
</body>
</html>
```
```		
[root@vmalma0 lab18_docker]# curl localhost:3000
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8">
  <title>lab18_docker_nginx:3000</title>
</head>
<body>
  <p>lab18_docker by stanwork43@gmail.com</p>
  <h1>Nginx on :3000</h1>      
</body>
</html>      
```

* Volumes:
```
[root@vmalma0 lab18_docker]# docker volume ls
DRIVER    VOLUME NAME
local     nginx_html
local     nginx_logs
[root@vmalma0 lab18_docker]# docker volume inspect nginx_html 
[
    {
        "CreatedAt": "2023-07-02T17:36:50+03:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/nginx_html/_data",
        "Name": "nginx_html",
        "Options": null,
        "Scope": "local"
    }
]
[root@vmalma0 lab18_docker]# docker volume inspect nginx_logs 
[
    {
        "CreatedAt": "2023-07-02T17:36:50+03:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/nginx_logs/_data",
        "Name": "nginx_logs",
        "Options": null,
        "Scope": "local"
    }
]

```

* Проверка записи в логи:
```
[root@vmalma0 lab18_docker]# tail /var/lib/docker/volumes/nginx_logs/_data/access.log 
172.17.0.1 - - [02/Jul/2023:14:40:53 +0000] "GET / HTTP/1.1" 200 211 "-" "curl/7.76.1" "-"
172.17.0.1 - - [02/Jul/2023:14:40:59 +0000] "GET / HTTP/1.1" 200 226 "-" "curl/7.76.1" "-"
```
```
[root@vmalma0 lab18_docker]# curl localhost/failcheck
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
[root@vmalma0 lab18_docker]# tail /var/lib/docker/volumes/nginx_logs/_data/error.log 
2023/07/02 14:36:51 [notice] 1#1: using the "epoll" event method
2023/07/02 14:36:51 [notice] 1#1: nginx/1.24.0
2023/07/02 14:36:51 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6) 
2023/07/02 14:36:51 [notice] 1#1: OS: Linux 5.14.0-284.11.1.el9_2.x86_64
2023/07/02 14:36:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1073741816:1073741816
2023/07/02 14:36:51 [notice] 1#1: start worker processes
2023/07/02 14:36:51 [notice] 1#1: start worker process 29
2023/07/02 14:36:51 [notice] 1#1: start worker process 30
2023/07/02 14:44:04 [error] 30#30: *3 open() "/usr/share/nginx/html/failcheck" failed (2: No such file or directory), client: 172.17.0.1, server: localhost, request: "GET /failcheck HTTP/1.1", host: "localhost"
```

* Лог выполнения:
[lab18_docker_log.txt](lab18_docker_log.txt)