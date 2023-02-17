#!/bin/bash

set -ex

if [ ! -z "$ENABLE_ITEMS_DIR" ] && [ "$ENABLE_ITEMS_DIR" = "True" ]; then
    sed -i 's/items_dir = /items_dir = \/var\/lib\/scrapyd\/items/g' /etc/scrapyd/scrapyd.conf
fi

systemctl start scrapyd.service

exec "$@"
