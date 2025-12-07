#!/bin/bash

if pgrep -x "gsimplecal" > /dev/null; then
    killall gsimplecal
else
    gsimplecal &
fi