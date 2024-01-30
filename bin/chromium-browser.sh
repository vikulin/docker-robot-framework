#!/bin/sh

exec /usr/bin/chromium-browser --disable-gpu --disable-dev-shm-usage --no-sandbox "$@"
