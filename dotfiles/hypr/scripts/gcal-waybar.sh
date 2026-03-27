#!/usr/bin/env bash
# Google Calendar events for Waybar (via gws CLI)

OUTPUT=$(gws calendar +agenda --days 1 --format json 2>/dev/null | grep -v '^Using keyring')

if [ -z "$OUTPUT" ]; then
  echo '{"text": "", "tooltip": "No events today"}'
  exit 0
fi

# Let jq handle everything — pure JSON output, no bash interpolation
echo "$OUTPUT" | jq -r '
  if .count == 0 then
    {"text": "󰃭 ", "tooltip": "No events today"}
  else
    (.events[0].start | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":")) as $time |
    (.events[0].summary // "No title") as $title |
    {
      text: ("󰃭 \($time) \($title)" | .[0:35]),
      tooltip: (
        "Today\u0027s events\n" + (
          [.events[] | "• \(.summary // "Untitled")\n  \(.start | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":")) – \(.end | split("T")[1] | split("+")[0] | split(":")[0:2] | join(":"))"] | join("\n")
        )
      )
    }
  end
'
