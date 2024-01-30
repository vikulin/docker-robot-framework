#!/bin/sh

exec /usr/local/bin/chromedriver --verbose --log-path=/var/log/chromedriver --no-sandbox "$@"