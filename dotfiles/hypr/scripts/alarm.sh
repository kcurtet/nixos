#!/usr/bin/env bash
# ============================================================================
# Alarm Manager for Hyprland
# Uses: notify-send (dunst), systemd timers, rofi
# ============================================================================
set -euo pipefail

ALARM_DIR="$HOME/.local/share/alarms"
SOUND_FILE="/run/current-system/sw/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
# Alternative sounds: complete, message, bell

mkdir -p "$ALARM_DIR"

play_sound() {
    # Try pw-play first (PipeWire), then paplay (PulseAudio)
    if command -v pw-play &>/dev/null && [[ -f "$SOUND_FILE" ]]; then
        pw-play "$SOUND_FILE" &
    elif command -v paplay &>/dev/null && [[ -f "$SOUND_FILE" ]]; then
        paplay "$SOUND_FILE" --volume=65536 &
    fi
}

notify_alarm() {
    local message="$1"
    play_sound
    notify-send -u critical -t 0 -a "Alarm" "⏰ ALARM" "$message"
}

# Add a new alarm
add_alarm() {
    local time_input="$1"
    local message="${2:-Alarm}"
    local alarm_id=$(date +%s%N | head -c 13)
    local alarm_file="$ALARM_DIR/alarm-$alarm_id"
    
    # Parse time input (supports: "10:30", "10m", "1h", "2h30m", "tomorrow 8:00")
    local delay_seconds
    
    if [[ "$time_input" =~ ^([0-9]+):([0-9]+)$ ]]; then
        # Format: HH:MM (today or tomorrow)
        local target_hour="${BASH_REMATCH[1]}"
        local target_min="${BASH_REMATCH[2]}"
        local now=$(date +%s)
        local target=$(date -j -f "%H:%M" "$target_hour:$target_min" +%s 2>/dev/null || \
                       date -d "$target_hour:$target_min" +%s 2>/dev/null)
        
        if [[ -z "$target" ]]; then
            echo "Error: Invalid time format" >&2
            exit 1
        fi
        
        # If time has passed today, schedule for tomorrow
        if [[ "$target" -le "$now" ]]; then
            target=$((target + 86400))
        fi
        delay_seconds=$((target - now))
        
    elif [[ "$time_input" =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        # Format: XhYm (e.g., 1h30m)
        delay_seconds=$((${BASH_REMATCH[1]} * 3600 + ${BASH_REMATCH[2]} * 60))
        
    elif [[ "$time_input" =~ ^([0-9]+)h$ ]]; then
        # Format: Xh (e.g., 2h)
        delay_seconds=$((${BASH_REMATCH[1]} * 3600))
        
    elif [[ "$time_input" =~ ^([0-9]+)m$ ]]; then
        # Format: Xm (e.g., 30m)
        delay_seconds=$((${BASH_REMATCH[1]} * 60))
        
    elif [[ "$time_input" =~ ^([0-9]+)s$ ]]; then
        # Format: Xs (e.g., 90s)
        delay_seconds=$((${BASH_REMATCH[1]}))
        
    elif [[ "$time_input" =~ ^([0-9]+)$ ]]; then
        # Format: X (minutes by default)
        delay_seconds=$((${BASH_REMATCH[1]} * 60))
        
    else
        echo "Error: Unknown time format. Use: HH:MM, Xm, Xh, XhYm" >&2
        exit 1
    fi
    
    if [[ "$delay_seconds" -lt 1 ]]; then
        echo "Error: Alarm must be in the future" >&2
        exit 1
    fi
    
    local trigger_time=$(date -d "+$delay_seconds seconds" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                         date -j -v+${delay_seconds}S +"%Y-%m-%d %H:%M:%S")
    
    # Create alarm file with metadata
    cat > "$alarm_file" << EOF
MESSAGE=$message
TRIGGER_TIME=$trigger_time
DELAY_SECONDS=$delay_seconds
CREATED=$(date +"%Y-%m-%d %H:%M:%S")
EOF
    
    # Start background timer
    (
        sleep "$delay_seconds"
        notify_alarm "$message"
        rm -f "$alarm_file"
    ) &
    echo $! >> "$alarm_file"
    
    notify-send -u low -a "Alarm" "Alarm Set" "$message at $trigger_time"
    echo "Alarm set: $message at $trigger_time"
}

# List all alarms
list_alarms() {
    local alarms=()
    for f in "$ALARM_DIR"/alarm-*; do
        [[ -f "$f" ]] || continue
        local message=$(grep "^MESSAGE=" "$f" | cut -d= -f2-)
        local trigger=$(grep "^TRIGGER_TIME=" "$f" | cut -d= -f2-)
        alarms+=("$trigger - $message")
    done
    
    if [[ ${#alarms[@]} -eq 0 ]]; then
        echo "No active alarms"
        return
    fi
    
    printf '%s\n' "${alarms[@]}" | sort
}

# Remove alarm
remove_alarm() {
    local pattern="$1"
    for f in "$ALARM_DIR"/alarm-*; do
        [[ -f "$f" ]] || continue
        local message=$(grep "^MESSAGE=" "$f" | cut -d= -f2-)
        if [[ "$message" == *"$pattern"* ]]; then
            local pid=$(grep -E "^[0-9]+$" "$f" | tail -1)
            [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
            rm -f "$f"
            echo "Removed: $message"
            notify-send -u low -a "Alarm" "Alarm Removed" "$message"
        fi
    done
}

# Clear all alarms
clear_all() {
    for f in "$ALARM_DIR"/alarm-*; do
        [[ -f "$f" ]] || continue
        local pid=$(grep -E "^[0-9]+$" "$f" | tail -1)
        [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
        rm -f "$f"
    done
    notify-send -u low -a "Alarm" "Alarms Cleared" "All alarms removed"
    echo "All alarms cleared"
}

# Rofi interface
rofi_menu() {
    local options=(
        "➕ New Alarm"
        "📋 List Alarms"
        "🗑️ Clear All"
        "❌ Cancel"
    )
    
    local choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Alarm" -theme ~/.config/rofi/nord.rasi)
    
    case "$choice" in
        "➕ New Alarm")
            local time_input=$(rofi -dmenu -p "Time (HH:MM, 30m, 1h)" -theme ~/.config/rofi/nord.rasi)
            [[ -z "$time_input" ]] && exit 0
            local message=$(rofi -dmenu -p "Message" -theme ~/.config/rofi/nord.rasi)
            [[ -z "$message" ]] && message="Alarm"
            add_alarm "$time_input" "$message"
            ;;
        "📋 List Alarms")
            local alarms=$(list_alarms)
            echo "$alarms" | rofi -dmenu -i -p "Active Alarms" -theme ~/.config/rofi/nord.rasi
            ;;
        "🗑️ Clear All")
            clear_all
            ;;
    esac
}

# Quick timer menu
quick_timer() {
    local options=(
        "5m - 5 minutes"
        "10m - 10 minutes"
        "15m - 15 minutes"
        "25m - Pomodoro"
        "30m - 30 minutes"
        "45m - 45 minutes"
        "1h - 1 hour"
        "2h - 2 hours"
    )
    
    local choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Quick Timer" -theme ~/.config/rofi/nord.rasi)
    [[ -z "$choice" ]] && exit 0
    
    local time=$(echo "$choice" | cut -d' ' -f1)
    add_alarm "$time" "Timer"
}

# Usage
usage() {
    cat << EOF
Alarm Manager for Hyprland

Usage: alarm.sh [command] [args]

Commands:
  add <time> [message]  Add alarm (time: HH:MM, 30m, 1h, 1h30m)
  list                  List active alarms
  remove <pattern>      Remove alarms matching pattern
  clear                 Clear all alarms
  menu                  Open rofi menu
  quick                 Quick timer menu
  
Examples:
  alarm.sh add 09:00 "Wake up"
  alarm.sh add 30m "Break over"
  alarm.sh add 1h30m "Meeting"
  alarm.sh list
  alarm.sh remove "Break"
  alarm.sh clear
EOF
}

# Main
case "${1:-menu}" in
    add)   add_alarm "$2" "${3:-Alarm}" ;;
    list)  list_alarms ;;
    remove) remove_alarm "${2:-}" ;;
    clear) clear_all ;;
    menu)  rofi_menu ;;
    quick) quick_timer ;;
    -h|--help) usage ;;
    *)     usage ;;
esac
