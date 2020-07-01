#!/bin/bash

if test -n "${AUTOSIGN_PSK}"; then
  # Generate csr_attributes.yaml
  cat << EOF > /etc/puppetlabs/puppet/csr_attributes.yaml
---
custom_attributes:
  1.2.840.113549.1.9.7: 'hashed;$(CERTNAME=$(puppet config print certname) ruby -e 'require "openssl"; print Digest::SHA256.base64digest(ENV["AUTOSIGN_PSK"] + "/" + ENV["CERTNAME"] + "/puppetdb/production")')'
extension_requests:
  pp_role: puppetdb
  pp_environment: production
EOF

  # Get certificate
	if test -n "${DNS_ALT_NAMES}"; then
		DNS_ALT_NAMES_FLAG="--dns_alt_names=${DNS_ALT_NAMES}"
	fi
  puppet ssl submit_request --environment production $DNS_ALT_NAMES_FLAG --waitforcert 60
fi
