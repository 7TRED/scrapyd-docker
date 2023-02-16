#!/bin/bash

set -ex

systemctl start scrapyd.service

exec "$@"
