#!/bin/bash

#
# Takes screenshot
# Blurs the current wallpaper and blurs
# Locks the screen
#

ICON="$HOME/Pictures/i3lock/lock-icon-keanu.png"
TMPBG='/tmp/lockscreen.png'
TMPICON='/tmp/tmplockicon.png'

# Screenshot, blur, composite
scrot "$TMPBG"
convert "$TMPBG" -blur 0x3 "$TMPBG"
cp $ICON $TMPICON
convert -resize 250% "$TMPICON" "$TMPICON"
convert "$TMPBG" "$ICON" -gravity center -composite "$TMPBG"

# Lock the screen
i3lock -i "$TMPBG"
