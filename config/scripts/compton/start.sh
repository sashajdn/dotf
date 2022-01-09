#!/bin/bash

#
# Script to run compton with blur effect
# Uses config in ~/.config/compton/compton.conf
# First checks if compton is running.
# Kills if true
#

if pgrep -x "compton" > /dev/null
then
	pkill -9 "compton"
fi
compton -b --config ~/.config/compton/compton.conf
