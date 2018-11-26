FROM ubuntu:bionic

EXPOSE 8080 8081

ENV RELEASE=bionic

ENV \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PUPPETDB_VERSION=5.2.6-1${RELEASE} \
    POSTGRES_SUBNAME=//postgresql:5432/puppetdb \
    POSTGRES_USER=puppetdb \
    POSTGRES_PASSWORD=puppetdb \
    PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppet5-release-${RELEASE}.deb \
  && dpkg -i puppet5-release-${RELEASE}.deb \
  && rm puppet5-release-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y puppetdb=$PUPPETDB_VERSION puppet-agent libreadline7 \
  && rm -rf /var/lib/apt/lists/*

# Setting
RUN puppet config set dns_alt_names puppetdb --section agent

# Allow JAVA_ARGS tuning
RUN sed -i -e 's@^JAVA_ARGS=\(.*\)$@JAVA_ARGS=\$\{JAVA_ARGS:-\1\}@' /etc/default/puppetdb

RUN mkdir -p /.puppetlabs/etc/puppet && chgrp -R 0 /.puppetlabs && chmod g=u -R /.puppetlabs \
  && chgrp -R 0 /etc/puppetlabs \
  && chgrp -R 0 /opt/puppetlabs \
  && chmod -R g=u /etc/puppetlabs/puppet \
  && chmod -R g=u /opt/puppetlabs/server/data/puppetdb

RUN echo "confdir = /etc/puppetlabs/puppet" > /.puppetlabs/etc/puppet/puppet.conf
RUN echo "ssldir = /etc/puppetlabs/puppet/ssl" >> /.puppetlabs/etc/puppet/puppet.conf

RUN \
  rm /etc/puppetlabs/puppetdb/conf.d/database.ini && \
  rm /etc/puppetlabs/puppetdb/conf.d/jetty.ini

RUN usermod -aG 0 -d / puppetdb
USER puppetdb

# Configure entrypoint
COPY docker-entrypoint.sh /
COPY docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
