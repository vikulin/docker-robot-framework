#!/bin/sh

exec /usr/bin/google-chrome-original --headless=new --no-sandbox --disable-gpu --single-process --disable-dev-shm-usage --disable-dev-tools --no-zygote --remote-debugging-port=9222 "$@"
