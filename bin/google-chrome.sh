#!/bin/sh

exec /usr/bin/google-chrome-original --disable-gpu --remote-debugging-port=9222 --no-sandbox --disable-dev-shm-usage "$@"
