#!/bin/sh

exec /usr/local/bin/chromedriver --verbose --log-path=/var/log/chromedriver --no-sandbox --remote-debugging-port=9222 --disable-gpu --disable-dev-shm-usage "$@"