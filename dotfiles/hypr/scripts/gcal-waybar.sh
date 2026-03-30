#!/usr/bin/env bash
# Google Calendar events for Waybar (via gws CLI)
# All stderr is silenced — waybar parses stdout as JSON, any extra output breaks it.
exec 2>/dev/null

OUTPUT=$(gws calendar +agenda --days 1 --format json 2>/dev/null | sed '/^Using /d')

if [ -z "$OUTPUT" ]; then
  echo '{"text": "", "tooltip": "No events today"}'
  exit 0
fi

COUNT=$(echo "$OUTPUT" | jq -r '.count // 0' 2>/dev/null)

if [ "$COUNT" = "0" ]; then
  echo '{"text": "󰃭 ", "tooltip": "No events today"}'
  exit 0
fi

# Extract time from ISO datetime (e.g. "2026-03-28T08:30:00+01:00" -> "08:30")
extract_time() {
  echo "$1" | sed 's/.*T\([0-9:]*\).*/\1/' | cut -d: -f1,2
}

TIME=$(extract_time "$(echo "$OUTPUT" | jq -r '.events[0].start' 2>/dev/null)")
TITLE=$(echo "$OUTPUT" | jq -r '.events[0].summary // "No title"' 2>/dev/null)
TEXT="󰃭 ${TIME} ${TITLE}"
TEXT="${TEXT:0:35}"

TOOLTIP="Today's events"
TOOLTIP+=$'\n'
TOOLTIP+=$(echo "$OUTPUT" | jq -r '
  [.events[] |
    "• \(.summary // "Untitled")\n  \(
      .start | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":")
    ) – \(
      .end | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":")
    )"
  ] | join("\n")
' 2>/dev/null)

jq -nc \
  --arg text "$TEXT" \
  --arg tooltip "$TOOLTIP" \
  '{text: $text, tooltip: $tooltip}' 2>/dev/null
