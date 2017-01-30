FROM mdelapenya/liferay-portal:7-ce-ga3-tomcat-hsql
MAINTAINER Manuel de la Peña <manuel.delapenya@liferay.com>

ENV DEBIAN_FRONTEND noninteractive

USER root

# Install packages
RUN echo 'deb http://repo.mysql.com/apt/debian jessie mysql-5.7' > /etc/apt/sources.list.d/mysql-5.7.list && \
  gpg --export 5072E1F5 > /etc/apt/trusted.gpg.d/5072E1F5.gpg && \
  gpg --recv-keys 5072E1F5 && \
  gpg --export 5072E1F5 > /etc/apt/trusted.gpg.d/5072E1F5.gpg && \
  apt-get update && \
  apt-get -y install supervisor mysql-server="5.7.17-1debian8" pwgen && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add image configuration and scripts
ADD start-tomcat.sh /start-tomcat.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD mysql-setup.sh /mysql-setup.sh
RUN chmod 755 /*.sh

ADD portal-ext.properties $LIFERAY_HOME/portal-ext.properties

RUN chown -R liferay:liferay $LIFERAY_HOME

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/liferay/data"]

EXPOSE 8080 3306

ENTRYPOINT ["/run.sh"]