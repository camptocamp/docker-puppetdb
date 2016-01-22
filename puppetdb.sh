#!/bin/sh

if test -n "${ENABLE_HTTP}" && ${ENABLE_HTTP}; then
  echo "Enable clear-text HTTP."
  sed -i -E 's/^#?\s*host = .*/host = 0.0.0.0/' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
fi

if test -n "${NODE_PURGE_TTL}"; then
  echo "node-purge-ttl = ${NODE_PURGE_TTL}" >> /etc/puppetlabs/puppetdb/conf.d/database.ini
fi

exec /opt/puppetlabs/server/bin/puppetdb foreground
