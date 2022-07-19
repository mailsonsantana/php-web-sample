FROM registry.access.redhat.com/ubi8/ubi

#Envs
ENV PHP_VERSION=7.4\
    NAME=Manutencao

#Update/Install
RUN yum -y module enable php:$PHP_VERSION
RUN yum update --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos -y && rm -rf /var/cache/yum
RUN yum install --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos \
		httpd php php-soap php-xml php-curl php-pecl-zendopcache php-gd php-cli \
		php-mbstring php-ldap php-zip php-fileinfo php-pgsql -y && \
		rm -rf /var/cache/yum
#Files
ADD ./src /var/www/html

#Rootless/Owner
RUN chown -R apache:apache /var/www/html
#    chmod 710 /run/httpd && \
#    chown apache:apache /run/httpd && \
#    chmod 700 /run/httpd/htcacheclean && \
#    chown apache:apache /run/httpd/htcacheclean && \
#    chown -R apache /var/log/httpd && \
#    setcap cap_net_bind_service=+epi /usr/sbin/httpd

#Permissions
RUN /bin/bash -c 'find /var/www/html -type f -exec chmod 0640 {} \;'
RUN /bin/bash -c 'find /var/www/html -type d -exec chmod 2750 {} \;'

#Labels
LABEL maintainer="Mailson"
LABEL io.k8s.description="Imagem base para aplicações PHP versão ${PHP_VERSION}" \
      io.k8s.display-name="${NAME}" \
      io.openshift.expose-services="80:http" \
      io.openshift.tags="php,apache"

#Workdir
WORKDIR /var/www/html

#Apache Flags
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf && \
    echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf && \
    echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf && \
    echo "TraceEnable Off" >> /etc/httpd/conf/httpd.conf

#User
USER root

#Expose
EXPOSE 80

#Start
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
