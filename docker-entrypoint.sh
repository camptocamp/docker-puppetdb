#!/bin/bash

#DIR=/docker-entrypoint.d
#
#if [[ -d "$DIR" ]]
#then
#  /bin/run-parts --regex '\.(sh|rb)$' "$DIR"
#fi

set -a

source /etc/default/puppetdb
source "${INSTALL_DIR}/ezbake-functions.sh"


CLASSPATH="${INSTALL_DIR}/puppetdb.jar"

COMMAND="${JAVA_BIN} ${JAVA_ARGS} ${LOG_APPENDER} \
         -Djava.security.egd=/dev/urandom \
         -cp "$CLASSPATH" \
         clojure.main -m puppetlabs.puppetdb.main \
         --config ${CONFIG} --bootstrap-config ${BOOTSTRAP_CONFIG} \
         ${TK_ARGS}"

exec ${COMMAND}
