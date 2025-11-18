#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Find and export network interfaces
for i in $(ip link | grep 'state UP' | cut -d':' -f2); do
    if [[ $i == e* ]]; then
        export POLYBAR_ETH_INTERFACE=$i
    elif [[ $i == w* ]]; then
        export POLYBAR_WLAN_INTERFACE=$i
    fi
done

# Launch Polybar, using default config location ~/.config/polybar/config.ini
polybar mybar &

echo "Polybar launched..."
