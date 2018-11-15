#!/bin/sh

echo "
subname = ${POSTGRES_SUBNAME}
username = ${POSTGRES_USER}
password = ${POSTGRES_PASSWORD}
" >> /etc/puppetlabs/puppetdb/conf.d/database.ini

if test -n "${POSTGRES_RO_SUBNAME}"; then
  if test -z "${POSTGRES_RO_USER}"; then
    POSTGRES_RO_USER=$POSTGRES_USER
  fi

  if test -z "${POSTGRES_RO_PASSWORD}"; then
    POSTGRES_RO_PASSWORD=$POSTGRES_PASSWORD
  fi

  echo "
subname = ${POSTGRES_RO_SUBNAME}
username = ${POSTGRES_RO_USER}
password = ${POSTGRES_RO_PASSWORD}
" >> /etc/puppetlabs/puppetdb/conf.d/database.ini
fi
