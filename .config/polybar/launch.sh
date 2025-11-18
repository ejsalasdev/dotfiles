#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Find and export network interfaces
for i in $(ip link | grep 'state UP' | cut -d':' -f2); do
    if [[ $i == e* ]]; then
        export POLYBAR_ETH_INTERFACE=$i
    elif [[ $i == w* ]]; then
        export POLYBAR_WLAN_INTERFACE=$i
    fi
done

# Launch Polybar on all connected monitors
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload mybar &
  done
else
  polybar --reload mybar &
fi

echo "Polybar launched..."
