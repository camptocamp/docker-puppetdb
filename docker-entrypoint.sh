#!/bin/bash

DIR=/docker-entrypoint.d

if [[ -d "$DIR" ]]
then
  /bin/run-parts --regex '\.(sh|rb)$' "$DIR"
fi

set -a

INSTALL_DIR="/opt/puppetlabs/server/apps/puppetdb"
JAVA_BIN="/usr/bin/java"
BOOTSTRAP_CONFIG="/etc/puppetlabs/puppetdb/bootstrap.cfg"
CLASSPATH="${INSTALL_DIR}/puppetdb.jar"
LOG_APPENDER="-Dlogappender=STDOUT"
restartfile="/opt/puppetlabs/server/data/puppetserver/restartcounter"

COMMAND="${JAVA_BIN} ${JAVA_ARGS} ${LOG_APPENDER} \
         -Djava.security.egd=/dev/urandom \
         -cp "$CLASSPATH" \
         clojure.main -m puppetlabs.puppetdb.main \
         --config ${CONFIG} --bootstrap-config ${BOOTSTRAP_CONFIG} \
         --restart-file "${restartfile}" \
         ${@}"

exec ${COMMAND}
