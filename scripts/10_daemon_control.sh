#!/bin/bash

if [[ $DISABLE_CARBON = 1 ]]; then
    echo Disabling carbon service
    test -d /etc/service/carbon && touch /etc/service/carbon/down
fi

if [[ $DISABLE_CARBON_AGGREGATOR = 1 ]]; then
    echo Disabling carbon-aggregator service
    test -d /etc/service/carbon-aggregator && touch /etc/service/carbon-aggregator/down
fi

if [[ $DISABLE_GRAPHITE_WEB = 1 ]]; then
    echo Disabling graphite-web service
    test -d /etc/service/graphite && touch /etc/service/graphite/down

fi
if [[ $DISABLE_NGINX = 1 ]]; then
    echo Disabling nginx service
    test -d /etc/service/nginx && touch /etc/service/nginx/down
fi

if [[ $DISABLE_STATSD = 1 ]]; then
    echo Disabling statsd service
    test -d /etc/service/statsd && touch /etc/service/statsd/down
fi
