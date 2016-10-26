#!/bin/sh

if test -n "${NODE_PURGE_TTL}"; then
  augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini" \
    set "/files//database.ini/database/node-purge-ttl"
fi
