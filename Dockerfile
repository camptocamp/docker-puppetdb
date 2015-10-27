FROM camptocamp/puppet-agent:1.2.6-1

MAINTAINER mickael.canevet@camptocamp.com

ENV PUPPETDB_VERSION 3.1.0-1puppetlabs1

RUN apt-get update \
  && apt-get install -y puppetdb=$PUPPETDB_VERSION \
  && rm -rf /var/lib/apt/lists/*

ADD puppetdb.sh /usr/local/sbin/puppetdb.sh

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

ENTRYPOINT ["puppetdb.sh"]
