FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

ENV RELEASE=jessie

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PUPPETDB_VERSION 3.2.2-1puppetlabs1

ENV JACKSON_VERSION 2.5.4

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y puppetdb=$PUPPETDB_VERSION \
  && rm -rf /var/lib/apt/lists/*

COPY puppetdb.sh /usr/local/sbin/puppetdb.sh

# TODO: use augeas
RUN sed -i -e 's/^classname = .*/classname = org.postgresql.Driver/' /etc/puppetlabs/puppetdb/conf.d/database.ini
RUN sed -i -e 's/^subprotocol = .*/subprotocol = postgresql/' /etc/puppetlabs/puppetdb/conf.d/database.ini
RUN sed -i -e 's@^subname = .*@subname = //postgresql:5432/puppetdb@' /etc/puppetlabs/puppetdb/conf.d/database.ini
RUN sed -i -E 's@^(#\s*)username = .*@username = puppetdb@' /etc/puppetlabs/puppetdb/conf.d/database.ini
RUN sed -i -E 's@^(#\s*)password = .*@password = puppetdb@' /etc/puppetlabs/puppetdb/conf.d/database.ini

# things done by "puppetdb ssl-setup -f" at first run
RUN sed -i -E 's@^(#\s*)ssl-host = .*@ssl-host = 0.0.0.0@' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
RUN sed -i -E 's@^(#\s*)ssl-port = .*@ssl-port = 8081@' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
RUN sed -i -E 's@^(#\s*)ssl-key = .*@ssl-key = /etc/puppetlabs/puppetdb/ssl/private.pem@' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
RUN sed -i -E 's@^(#\s*)ssl-cert = .*@ssl-cert = /etc/puppetlabs/puppetdb/ssl/public.pem@' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
RUN sed -i -E 's@^(#\s*)ssl-ca-cert = .*@ssl-ca-cert = /etc/puppetlabs/puppetdb/ssl/ca.pem@' /etc/puppetlabs/puppetdb/conf.d/jetty.ini

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetdb

# Configure Log appenders
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/${JACKSON_VERSION}/jackson-annotations-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetdb/
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/${JACKSON_VERSION}/jackson-core-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetdb/
ADD http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/${JACKSON_VERSION}/jackson-databind-${JACKSON_VERSION}.jar /opt/puppetlabs/server/apps/puppetdb/
ADD http://central.maven.org/maven2/net/logstash/logback/logstash-logback-encoder/4.5.1/logstash-logback-encoder-4.5.1.jar /opt/puppetlabs/server/apps/puppetdb/
ADD http://central.maven.org/maven2/com/github/juise/logstash-logback-layout/1.0/logstash-logback-layout-1.0.jar /opt/puppetlabs/server/apps/puppetdb/

RUN chmod +r /opt/puppetlabs/server/apps/puppetdb/*.jar

COPY logback.xml /etc/puppetlabs/puppetdb/
COPY request-logging.xml /etc/puppetlabs/puppetdb/

RUN sed -i 's/${JAVA_ARGS} ${LOG_APPENDER}/${LOG_APPENDER} ${JAVA_ARGS}/' /opt/puppetlabs/server/apps/puppetdb/cli/apps/foreground
RUN sed -i "s@\(puppetdb.jar\)@\1:\$\{INSTALL_DIR\}/logstash-logback-encoder-4.5.1.jar:\$\{INSTALL_DIR\}/logstash-logback-layout-1.0.jar:\$\{INSTALL_DIR\}/jackson-annotations-${JACKSON_VERSION}.jar:\$\{INSTALL_DIR\}/jackson-core-${JACKSON_VERSION}.jar:\$\{INSTALL_DIR\}/jackson-databind-${JACKSON_VERSION}.jar@" /opt/puppetlabs/server/apps/puppetdb/cli/apps/foreground

ENTRYPOINT ["puppetdb.sh"]
