FROM nginx:stable

#conf for logs in /log/nginx
COPY nginx.conf /etc/nginx/

#conf for :3000
COPY nginx_3000.conf /etc/nginx/conf.d/

#content:
COPY ./html/ /usr/share/nginx/html/


