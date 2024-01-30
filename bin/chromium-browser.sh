#!/bin/sh

exec /usr/bin/chromium-browser-original --disable-gpu --disable-dev-shm-usage --no-sandbox "$@"
