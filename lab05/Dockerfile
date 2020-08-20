FROM centos:centos7
LABEL MAINTAINER="deron73@inbox.ru"
COPY ./nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
RUN yum localinstall -y /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm -y && rm -rf /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm && yum clean packages -y
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
