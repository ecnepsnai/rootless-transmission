#!/bin/sh
set -e

if [ ! -f /config/settings.json ]; then
    cp /default_settings.json /config/settings.json
fi

/usr/local/bin/transmission-daemon -f -c /watch -g /config