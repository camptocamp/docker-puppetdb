#!/bin/sh

echo "
  set /augeas/context '/files//database.ini/database'
  set subname '${POSTGRES_SUBNAME}'
  set username '${POSTGRES_USER}'
  set password '${POSTGRES_PASSWORD}'
  " | augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini"

if test -n "${POSTGRES_RO_SUBNAME}"; then
  if test -z "${POSTGRES_RO_USER}"; then
    POSTGRES_RO_USER=$POSTGRES_USER
  fi

  if test -z "${POSTGRES_RO_PASSWORD}"; then
    POSTGRES_RO_PASSWORD=$POSTGRES_PASSWORD
  fi

  echo "
    set /augeas/context '/files//database.ini/read-database'
    set subname '${POSTGRES_RO_SUBNAME}'
    set username '${POSTGRES_RO_USER}'
    set password '${POSTGRES_RO_PASSWORD}'
    " | augtool -Ast "Puppet.lns incl /etc/puppetlabs/puppetdb/conf.d/database.ini"
fi
