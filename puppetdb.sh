#!/bin/sh

if test -n "${ENABLE_HTTP}" && ${ENABLE_HTTP}; then
  echo "Enable clear-text HTTP."
  sed -i -E 's/^#?\s*host = .*/host = 0.0.0.0/' /etc/puppetlabs/puppetdb/conf.d/jetty.ini
fi

/opt/puppetlabs/server/bin/puppetdb foreground
