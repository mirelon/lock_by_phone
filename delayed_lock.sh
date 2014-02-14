#!/bin/bash
echo "started delayed lock with pid $$"
sleep $1
gnome-screensaver-command -l