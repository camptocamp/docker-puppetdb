FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 8080 8081

ENV RELEASE=jessie

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

ENV PUPPETDB_VERSION 4.2.2-1puppetlabs1

ENV JACKSON_VERSION 2.5.4

ENV PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:$PATH

RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y puppetdb=$PUPPETDB_VERSION \
  && rm -rf /var/lib/apt/lists/*

# Setting
RUN puppet config set dns_alt_names puppetdb --section agent

# TODO: use augeas
RUN printf 'set /augeas/context /files//database.ini/database \n\
  set subname "//postgresql:5432/puppetdb" \n\
  set username "puppetdb" \n\
  set password "puppetdb" \n\
  print . \n\
  ' | augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini"

# things done by "puppetdb ssl-setup -f" at first run
RUN printf 'set /augeas/context /files//jetty.ini/jetty \n\
  set ssl-host "0.0.0.0" \n\
  set ssl-port "8081" \n\
  set ssl-key "/etc/puppetlabs/puppetdb/ssl/private.pem" \n\
  set ssl-cert "/etc/puppetlabs/puppetdb/ssl/public.pem" \n\
  set ssl-ca-cert "/etc/puppetlabs/puppetdb/ssl/ca.pem" \n\
  print . \n\
  ' | augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/jetty.ini"

# Allow JAVA_ARGS tuning
RUN printf 'set /augeas/context /files/etc/default/puppetdb \n\
  set JAVA_ARGS "${JAVA_ARGS:-1}" \n\
  print . \n\
  ' | augtool -Ast "Shellvars.lns incl /etc/default/puppetdb"

# Configure entrypoint
COPY docker-entrypoint.sh /
COPY docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["puppetdb", "foreground"]
