#!/bin/sh

if test -n "${ENABLE_HTTP}" && ${ENABLE_HTTP}; then
  echo "Enable clear-text HTTP."
  augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/jetty.ini" \
    set "/files//jetty.ini/jetty/host" "0.0.0.0"
fi
