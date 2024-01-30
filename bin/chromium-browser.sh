#!/bin/sh

exec /usr/bin/chromium-browser-original --disable-gpu --remote-debugging-port=9222 --no-sandbox "$@"
