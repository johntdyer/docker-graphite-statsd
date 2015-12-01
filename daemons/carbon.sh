#!/bin/bash

exec /usr/bin/python /opt/graphite/bin/carbon-cache.py start --nodaemon --syslog
