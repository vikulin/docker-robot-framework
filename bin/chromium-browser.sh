#!/bin/sh

exec /usr/bin/chromium-browser-original --disable-gpu --no-sandbox "$@"
