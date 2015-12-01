#!/bin/bash

exec /usr/bin/python /opt/graphite/bin/carbon-aggregator.py start --nodaemon --syslog
