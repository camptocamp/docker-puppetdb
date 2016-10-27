#!/bin/sh

if test -n "${POSTGRES_USER}"; then
  augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini" \
    set "/files//database.ini/database/username" "${POSTGRES_USER}"
fi

if test -n "${POSTGRES_PASSWORD}"; then
  augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini" \
    set "/files//database.ini/database/password" "${POSTGRES_PASSWORD}"
fi
