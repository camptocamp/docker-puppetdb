FROM docker.io/puppet/puppetdb:6.11.0

COPY docker-entrypoint.d/* /docker-entrypoint.d/
