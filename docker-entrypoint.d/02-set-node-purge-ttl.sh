#!/bin/sh

if test -n "${NODE_PURGE_TTL}"; then
  echo "node-purge-ttl = ${NODE_PURGE_TTL}" >> /etc/puppetlabs/puppetdb/conf.d/database.ini
fi
