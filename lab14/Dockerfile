FROM alpine:3.12.1
MAINTAINER deron73@mail.ru
RUN set -x \
    && apk add --update nginx \ 
    && rm -rf /var/cache/apk/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
CMD ["nginx", "-g", "daemon off;"]
