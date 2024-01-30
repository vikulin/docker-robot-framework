#!/bin/sh

exec /usr/bin/google-chrome-original --disable-gpu --remote-debugging-port=9222 --headless --no-sandbox "$@"
