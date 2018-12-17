FROM centos:7

EXPOSE 8080 8081

ENV RELEASE=el-7

ENV \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PUPPETDB_VERSION=6.0.1-1.el7 \
    PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH \
	CONFIG=/etc/puppetlabs/puppetdb/conf.d \
	JAVA_ARG=-Xmx192m

RUN yum install -y http://yum.puppet.com/puppet6/puppet-release-${RELEASE}.noarch.rpm && \
    yum install -y puppetdb-$PUPPETDB_VERSION puppet-agent && \
	yum install -y crontabs && \
	yum clean all && \
	rm -rf /var/cache/yum

RUN mkdir -p /.puppetlabs/etc/puppet && chgrp -R 0 /.puppetlabs && chmod g=u -R /.puppetlabs \
  && mkdir -p /etc/puppetlabs/puppet/ssl \
  && chgrp 0 -R /etc/puppetlabs/puppet/ssl && chmod -R 0771 /etc/puppetlabs/puppet/ssl \
  && chgrp -R 0 /etc/puppetlabs \
  && chgrp -R 0 /opt/puppetlabs \
  && chmod -R g=u /etc/puppetlabs/puppet \
  && chmod -R g=u /opt/puppetlabs/server/data/puppetdb \
  && mkdir /opt/puppetlabs/server/data/puppetserver \
  && chgrp -R 0 /opt/puppetlabs/server/data/puppetserver \
  && chmod -R g=u /opt/puppetlabs/server/data/puppetserver

RUN echo "confdir = /etc/puppetlabs/puppet" > /.puppetlabs/etc/puppet/puppet.conf
RUN echo "ssldir = /etc/puppetlabs/puppet/ssl" >> /.puppetlabs/etc/puppet/puppet.conf
RUN echo "dns_alt_names = puppetdb" >> /.puppetlabs/etc/puppet/puppet.conf

RUN \
  rm /etc/puppetlabs/puppetdb/conf.d/database.ini && \
  rm /etc/puppetlabs/puppetdb/conf.d/jetty.ini

VOLUME ["/etc/puppetlabs/puppet/ssl", "/opt/puppetlabs/server/data/puppetdb"]

RUN usermod -aG 0 -d / puppetdb
USER puppetdb

# Configure entrypoint
COPY docker-entrypoint.sh /
COPY docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
