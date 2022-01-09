#!/bin/bash

killall -1 polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar main -c ~/.config/polybar/config.ini & 
polybar secondary -c ~/.config/polybar/config.ini & 
