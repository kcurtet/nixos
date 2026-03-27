#!/usr/bin/env bash
# Google Calendar events for Waybar (via gws CLI)
# Output: Waybar JSON {"text": "...", "tooltip": "..."}

OUTPUT=$(gws calendar +agenda --days 1 --format json 2>/dev/null)

if [ -z "$OUTPUT" ]; then
  echo '{"text": "", "tooltip": "No events today"}'
  exit 0
fi

COUNT=$(echo "$OUTPUT" | jq -r '.count // 0')

if [ "$COUNT" -eq 0 ]; then
  echo '{"text": "󰃭 ", "tooltip": "No events today"}'
  exit 0
fi

# Build text: show next event summary (truncated)
NEXT_EVENT=$(echo "$OUTPUT" | jq -r '.events[0].summary // "No title"' | cut -c1-25)
NEXT_START=$(echo "$OUTPUT" | jq -r '.events[0].start // ""' | sed 's/T/ /' | cut -c12-16)
TEXT="󰃭 ${NEXT_START} ${NEXT_EVENT}"

# Build tooltip: all events with times
TOOLTIP="<b>Today's events</b>\n"
TOOLTIP+=$(echo "$OUTPUT" | jq -r '
  .events[] |
  "• \(.summary // "Untitled")\n  \(.start | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":")) – \(.end | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":"))\n"
')

echo "{\"text\": \"$TEXT\", \"tooltip\": \"$TOOLTIP\"}"
