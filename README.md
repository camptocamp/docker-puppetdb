PuppetDB Docker image
======================

[![Docker Pulls](https://img.shields.io/docker/pulls/camptocamp/puppetdb.svg)](https://hub.docker.com/r/camptocamp/puppetdb/)
[![Build Status](https://img.shields.io/travis/camptocamp/docker-puppetdb/master.svg)](https://travis-ci.org/camptocamp/docker-puppetdb)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

Available environment variables:
--------------------------------

### ENABLE_HTTP

You can enable clear text HTTP connections to the PuppetDB with:

```shell
docker run --rm -e ENABLE_HTTP='true' camptocamp/puppetdb
```

### NODE_PURGE_TTL

Set `node-purge-ttl` with:

```shell
docker run --rm -e NODE_PURGE_TTL='15d' camptocamp/puppetdb
```

