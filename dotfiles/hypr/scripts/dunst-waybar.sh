#!/usr/bin/env bash
# Dunst notification indicator for Waybar
set -euo pipefail

count=$(dunstctl count history)
paused=$(dunstctl is-paused)

if [[ "$paused" == "true" ]]; then
    echo '{"text": "󰂛 ", "tooltip": "Notifications paused", "class": "paused"}'
elif [[ "$count" -gt 0 ]]; then
    echo "{\"text\": \"󰂚  ${count}\", \"tooltip\": \"${count} notifications\", \"class\": \"has-notifs\"}"
else
    echo '{"text": "󰂜 ", "tooltip": "No notifications", "class": "empty"}'
fi
