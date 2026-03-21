#!/usr/bin/env bash
# Rofi power menu — Nord themed
set -euo pipefail

options="󰌾  Lock\n󰍃  Logout\n󰤄  Suspend\n󰜉  Reboot\n󰐥  Shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/nord.rasi -lines 5)

case "$chosen" in
    *Lock*)     swaylock ;;
    *Logout*)   hyprctl dispatch exit ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
