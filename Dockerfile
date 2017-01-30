FROM openjdk:8-jdk
MAINTAINER Manuel de la Peña <manuel.delapenya@liferay.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LIFERAY_HOME=/liferay
ENV LIFERAY_TOMCAT_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.0.2%20GA3/liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip/download

# Install packages
RUN echo 'deb http://repo.mysql.com/apt/debian jessie mysql-5.7' > /etc/apt/sources.list.d/mysql-5.7.list && \
  gpg --export 5072E1F5 > /etc/apt/trusted.gpg.d/5072E1F5.gpg && \
  gpg --recv-keys 5072E1F5 && \
  gpg --export 5072E1F5 > /etc/apt/trusted.gpg.d/5072E1F5.gpg && \
  apt-get update && \
  apt-get -y install curl supervisor mysql-server="5.7.17-1debian8" pwgen unzip && \
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

# Configure /liferay folder
RUN mkdir -p "$LIFERAY_HOME"
WORKDIR $LIFERAY_HOME
RUN set -x && \
			curl -fSL "$LIFERAY_TOMCAT_URL" -o liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip && \
			unzip liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip && \
			rm liferay-ce-portal-tomcat-7.0-ga3-20160804222206210.zip && \
      cp -R $LIFERAY_HOME/liferay-ce-portal-7.0-ga3/* $LIFERAY_HOME/ && \
      rm -fr $LIFERAY_HOME/liferay-ce-portal-7.0-ga3

ADD portal-ext.properties $LIFERAY_HOME/portal-ext.properties

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql", "/liferay/data"]

EXPOSE 8080 3306

CMD ["/run.sh"]