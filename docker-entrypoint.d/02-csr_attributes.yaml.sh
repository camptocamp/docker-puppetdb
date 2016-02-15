#!/bin/bash

if getent hosts rancher-metadata; then
  # Generate csr_attributes.yaml
  echo $(curl http://rancher-metadata/latest/self/service/name 2> /dev/null):$(curl http://rancher-metadata/latest/self/service/uuid 2> /dev/null) > /etc/puppetlabs/puppet/csr_attributes.yaml

  # Get certificate
  if getent hosts puppetca; then
    puppet agent -t --noop --server puppetca
  else
    puppet agent -t --noop
  fi
fi
