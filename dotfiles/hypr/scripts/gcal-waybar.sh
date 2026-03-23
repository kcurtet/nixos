#!/usr/bin/env bash
# Google Calendar events for Waybar
# Returns JSON with text, tooltip, and class

set -euo pipefail

# Calendars to filter out (add calendars you don't want to display)
FILTERED_CALENDARS=(
  "Fases de la luna"
  "Festivos en España"
)

# Get events from Google Calendar
RESULT=$(gws calendar +agenda --days 7 --format json 2>/dev/null || echo '{"count":0,"events":[]}')

# Filter out events from unwanted calendars
FILTERED_RESULT=$(echo "$RESULT" | jq --arg calendars "$(IFS='|'; echo "${FILTERED_CALENDARS[*]}")" '
  .events |= map(select(.calendar as $c | $calendars | split("|") | index($c) | not))
  | .count = (.events | length)')

COUNT=$(echo "$FILTERED_RESULT" | jq -r '.count // 0')

if [[ "$COUNT" -eq 0 ]]; then
  echo '{"text": "󰃭  No events", "tooltip": "No upcoming events", "class": "idle"}'
  exit 0
fi

# Get first event for display
FIRST_EVENT=$(echo "$FILTERED_RESULT" | jq '.events[0]' 2>/dev/null || echo '{}')
EVENT_SUMMARY=$(echo "$FIRST_EVENT" | jq -r '.summary // "(No title)"' 2>/dev/null || echo "Event")
EVENT_START=$(echo "$FIRST_EVENT" | jq -r '.start // ""' 2>/dev/null || echo "")

# Format start time
FORMATTED_TIME=""
if [[ -n "$EVENT_START" ]]; then
  if [[ "$EVENT_START" == *"T"* ]]; then
    # Has time component (ISO 8601 with timezone)
    FORMATTED_TIME=$(date -d "$EVENT_START" "+%H:%M" 2>/dev/null || echo "")
  else
    # All-day event (just date)
    FORMATTED_TIME=$(date -d "$EVENT_START" "+%a %d/%m" 2>/dev/null || echo "")
  fi
fi

# Build tooltip with all events (up to 8)
TOOLTIP_LINES=""
EVENT_COUNT=$(echo "$FILTERED_RESULT" | jq '.events | length')
MAX_EVENTS=$((EVENT_COUNT < 8 ? EVENT_COUNT : 8))

for i in $(seq 0 $((MAX_EVENTS - 1))); do
  EVT_SUMMARY=$(echo "$FILTERED_RESULT" | jq -r ".events[$i].summary // \"(No title)\"")
  EVT_START=$(echo "$FILTERED_RESULT" | jq -r ".events[$i].start // \"\"")

  formatted=""
  if [[ -n "$EVT_START" ]]; then
    if [[ "$EVT_START" == *"T"* ]]; then
      formatted=$(date -d "$EVT_START" "+%H:%M" 2>/dev/null || echo "$EVT_START")
    else
      formatted=$(date -d "$EVT_START" "+%a %d/%m" 2>/dev/null || echo "$EVT_START")
    fi
  fi

  if [[ -n "$formatted" ]]; then
    TOOLTIP_LINES="${TOOLTIP_LINES}• $formatted $EVT_SUMMARY\n"
  else
    TOOLTIP_LINES="${TOOLTIP_LINES}• $EVT_SUMMARY\n"
  fi
done

TOOLTIP=$(echo -e "$TOOLTIP_LINES")

# Determine class based on if there's an event soon
CLASS="idle"
if [[ -n "$EVENT_START" ]]; then
  NOW=$(date +%s)
  EVENT_TIMESTAMP=$(date -d "$EVENT_START" +%s 2>/dev/null || echo 0)
  TIME_DIFF=$((EVENT_TIMESTAMP - NOW))

  if [[ $TIME_DIFF -le 3600 ]] && [[ $TIME_DIFF -ge -1800 ]]; then
    CLASS="urgent"  # Event within the hour or started recently
  elif [[ $TIME_DIFF -le 86400 ]]; then
    CLASS="active"   # Event within 24 hours
  fi
fi

# Format text (truncate if too long)
TEXT=$(echo "$EVENT_SUMMARY" | cut -c1-30)
if [[ -n "$FORMATTED_TIME" ]]; then
  TEXT="$TEXT · $FORMATTED_TIME"
fi

# Output JSON
jq -n \
  --arg text "$TEXT" \
  --arg tooltip "$TOOLTIP" \
  --arg class "$CLASS" \
  '{text: $text, tooltip: $tooltip, class: $class}'

