#!/bin/sh

exec /usr/bin/chromium-browser --disable-gpu --no-sandbox "$@"
