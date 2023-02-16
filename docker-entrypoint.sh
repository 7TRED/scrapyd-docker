#!/bin/bash

set -ex

if [ ! -z "$SCRAPYD_USERNAME" ] && [ ! -z "$SCRAPYD_PASSWORD" ]; then
    sed -i "s/username = /username = $SCRAPYD_USERNAME/g" /etc/scrapyd/scrapyd.conf
    sed -i "s/password = /password = $SCRAPYD_USERNAME/g" /etc/scrapyd/scrapyd.conf
fi

systemctl start scrapyd.service

exec "$@"
