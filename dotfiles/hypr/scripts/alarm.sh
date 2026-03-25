#!/usr/bin/env bash
# ============================================================================
# Alarm Manager for Hyprland - systemd persistent backend
# Uses: systemd --user timers, notify-send, pw-play
# Alarms persist across reboots
# ============================================================================
set -euo pipefail

ALARM_DIR="$HOME/.local/share/alarms"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SOUND_FILE="/run/current-system/sw/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

mkdir -p "$ALARM_DIR" "$SYSTEMD_DIR"

# ============================================================================
# Helpers
# ============================================================================

play_sound() {
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

# Generate a safe systemd unit name (alphanumeric + dash only)
sanitize_name() {
    echo "$1" | tr -c '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]' | sed 's/-\+/-/g; s/^-\|-$//g'
}

# ============================================================================
# Systemd unit management
# ============================================================================

create_systemd_units() {
    local alarm_id="$1"
    local message="$2"
    local delay_seconds="$3"
    local trigger_time="$4"
    local calendar_time="$5"  # Empty for relative timers
    
    local safe_id=$(sanitize_name "$alarm_id")
    local unit_name="alarm-${safe_id}"
    
    # Create service unit
    cat > "$SYSTEMD_DIR/${unit_name}.service" << EOF
[Unit]
Description=Alarm: ${message}
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash -c 'notify-send -u critical -t 0 -a "Alarm" "⏰ ALARM" "${message}" && pw-play ${SOUND_FILE}'
Environment=DISPLAY=:0
Environment=XDG_RUNTIME_DIR=/run/user/$(id -u)

[Install]
WantedBy=default.target
EOF

    # Create timer unit
    if [[ -n "$calendar_time" ]]; then
        # Absolute time (OnCalendar)
        cat > "$SYSTEMD_DIR/${unit_name}.timer" << EOF
[Unit]
Description=Timer for alarm: ${message}

[Timer]
OnCalendar=${calendar_time}
Persistent=true

[Install]
WantedBy=timers.target
EOF
    else
        # Relative time (OnActiveSec)
        cat > "$SYSTEMD_DIR/${unit_name}.timer" << EOF
[Unit]
Description=Timer for alarm: ${message}

[Timer]
OnActiveSec=${delay_seconds}s
Persistent=false

[Install]
WantedBy=timers.target
EOF
    fi
    
    # Store alarm metadata
    cat > "$ALARM_DIR/${unit_name}" << EOF
MESSAGE=${message}
TRIGGER_TIME=${trigger_time}
DELAY_SECONDS=${delay_seconds}
CREATED=$(date +"%Y-%m-%d %H:%M:%S")
UNIT_NAME=${unit_name}
EOF
    
    # Reload systemd, enable and start timer
    systemctl --user daemon-reload
    systemctl --user enable --now "${unit_name}.timer"
}

remove_systemd_units() {
    local unit_name="$1"
    
    systemctl --user stop "${unit_name}.timer" 2>/dev/null || true
    systemctl --user disable "${unit_name}.timer" 2>/dev/null || true
    
    # Also remove symlink manually (in case systemd already unloaded the unit)
    rm -f "$SYSTEMD_DIR/timers.target.wants/${unit_name}.timer"
    rm -f "$SYSTEMD_DIR/${unit_name}.timer" "$SYSTEMD_DIR/${unit_name}.service"
    rm -f "$ALARM_DIR/${unit_name}"
    
    systemctl --user daemon-reload
}

# ============================================================================
# Commands
# ============================================================================

add_alarm() {
    local time_input="$1"
    local message="${2:-Alarm}"
    local alarm_id=$(date +%s%N | head -c 13)
    
    local delay_seconds=""
    local calendar_time=""
    local trigger_time=""
    
    # Parse time input
    if [[ "$time_input" =~ ^([0-9]+):([0-9]+)$ ]]; then
        # Format: HH:MM (absolute time)
        local target_hour="${BASH_REMATCH[1]}"
        local target_min="${BASH_REMATCH[2]}"
        local now=$(date +%s)
        local target=$(date -d "${target_hour}:${target_min}" +%s 2>/dev/null || \
                       date -j -f "%H:%M" "${target_hour}:${target_min}" +%s 2>/dev/null)
        
        if [[ -z "$target" ]]; then
            echo "Error: Invalid time format" >&2
            exit 1
        fi
        
        # If time has passed today, schedule for tomorrow
        if [[ "$target" -le "$now" ]]; then
            target=$((target + 86400))
        fi
        
        delay_seconds=$((target - now))
        trigger_time=$(date -d "@${target}" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                       date -j -f "%s" "${target}" +"%Y-%m-%d %H:%M:%S")
        
        # Use OnCalendar for absolute time (more precise across reboots)
        calendar_time=$(date -d "@${target}" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                        date -j -f "%s" "${target}" +"%Y-%m-%d %H:%M:%S")
        
    elif [[ "$time_input" =~ ^([0-9]+)h([0-9]+)m$ ]]; then
        delay_seconds=$((${BASH_REMATCH[1]} * 3600 + ${BASH_REMATCH[2]} * 60))
        
    elif [[ "$time_input" =~ ^([0-9]+)h$ ]]; then
        delay_seconds=$((${BASH_REMATCH[1]} * 3600))
        
    elif [[ "$time_input" =~ ^([0-9]+)m$ ]]; then
        delay_seconds=$((${BASH_REMATCH[1]} * 60))
        
    elif [[ "$time_input" =~ ^([0-9]+)s$ ]]; then
        delay_seconds=$((${BASH_REMATCH[1]}))
        
    elif [[ "$time_input" =~ ^([0-9]+)$ ]]; then
        delay_seconds=$((${BASH_REMATCH[1]} * 60))
        
    else
        echo "Error: Unknown time format. Use: HH:MM, Xm, Xh, XhYm" >&2
        exit 1
    fi
    
    if [[ "$delay_seconds" -lt 1 ]]; then
        echo "Error: Alarm must be in the future" >&2
        exit 1
    fi
    
    # Calculate trigger time if not already set (relative timers)
    if [[ -z "$trigger_time" ]]; then
        trigger_time=$(date -d "+${delay_seconds} seconds" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || \
                       date -j -v+${delay_seconds}S +"%Y-%m-%d %H:%M:%S")
    fi
    
    create_systemd_units "$alarm_id" "$message" "$delay_seconds" "$trigger_time" "$calendar_time"
    
    notify-send -u low -a "Alarm" "Alarm Set" "$message at $trigger_time"
    echo "Alarm set: $message at $trigger_time"
}

list_alarms() {
    # Clean up expired alarms first
    cleanup_expired 2>/dev/null || true
    
    local timers=$(systemctl --user list-timers --all --no-legend "alarm-*.timer" 2>/dev/null || true)
    local found=0

    if [[ -z "$timers" ]]; then
        echo "No active alarms"
        return
    fi

    while read -r line; do
        [[ -n "$line" ]] || continue

        local unit=$(echo "$line" | awk '{print $1}' | sed 's/.timer$//')

        # Skip expired alarms (shows "X ago" in the time column)
        if echo "$line" | grep -q "ago"; then
            # Clean up expired timer
            remove_systemd_units "$unit" 2>/dev/null || true
            continue
        fi

        local next_trigger=$(echo "$line" | awk '{print $4, $5}')

        # Get message from metadata file
        local meta_file="$ALARM_DIR/${unit}"
        local message="Alarm"
        if [[ -f "$meta_file" ]]; then
            message=$(grep "^MESSAGE=" "$meta_file" | cut -d= -f2-)
        fi

        echo "$next_trigger - $message"
        found=1
    done <<< "$timers"

    [[ "$found" -eq 0 ]] && echo "No active alarms"
}

remove_alarm() {
    local pattern="$1"
    local found=0
    
    for meta_file in "$ALARM_DIR"/alarm-*; do
        [[ -f "$meta_file" ]] || continue
        local message=$(grep "^MESSAGE=" "$meta_file" | cut -d= -f2-)
        local unit_name=$(grep "^UNIT_NAME=" "$meta_file" | cut -d= -f2-)
        
        if [[ "$message" == *"$pattern"* ]]; then
            remove_systemd_units "$unit_name"
            echo "Removed: $message"
            notify-send -u low -a "Alarm" "Alarm Removed" "$message"
            found=1
        fi
    done
    
    [[ "$found" -eq 0 ]] && echo "No alarm matching '$pattern' found"
}

# Clean up expired alarms (timers that already fired)
cleanup_expired() {
    local count=0
    
    # Get timers that show "ago" (already fired)
    # Extract unit name (alarm-*.timer) from lines containing "ago"
    local expired=$(systemctl --user list-timers --all --no-legend "alarm-*.timer" 2>/dev/null | grep "ago" | grep -oE 'alarm-[0-9]+\.timer' | sed 's/.timer$//')
    
    for unit_name in $expired; do
        [[ -n "$unit_name" ]] || continue
        remove_systemd_units "$unit_name"
        count=$((count + 1))
    done
    
    [[ "$count" -gt 0 ]] && echo "Cleaned up $count expired alarms"
}

clear_all() {
    local count=0
    for meta_file in "$ALARM_DIR"/alarm-*; do
        [[ -f "$meta_file" ]] || continue
        local unit_name=$(grep "^UNIT_NAME=" "$meta_file" | cut -d= -f2-)
        remove_systemd_units "$unit_name"
        count=$((count + 1))
    done
    
    if [[ "$count" -gt 0 ]]; then
        notify-send -u low -a "Alarm" "Alarms Cleared" "Removed $count alarms"
        echo "Cleared $count alarms"
    else
        echo "No alarms to clear"
    fi
}

# ============================================================================
# Rofi interface
# ============================================================================

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

# Direct notification (for systemd service)
notify() {
    local message="${1:-Alarm}"
    notify_alarm "$message"
}

# ============================================================================
# Usage
# ============================================================================

usage() {
    cat << EOF
Alarm Manager for Hyprland (systemd backend)

Usage: alarm [command] [args]

Commands:
  add <time> [message]  Add alarm (time: HH:MM, 30m, 1h, 1h30m)
  list                  List active alarms
  remove <pattern>      Remove alarms matching pattern
  clear                 Clear all alarms
  cleanup               Remove expired alarms
  menu                  Open rofi menu
  quick                 Quick timer menu
  notify [message]      Trigger alarm notification (for systemd)

Examples:
  alarm add 09:00 "Wake up"
  alarm add 30m "Break over"
  alarm add 1h30m "Meeting"
  alarm list
  alarm remove "Break"
  alarm clear

Alarms persist across reboots via systemd user timers.
View with: systemctl --user list-timers alarm-*
EOF
}

# Main
case "${1:-menu}" in
    add)    add_alarm "$2" "${3:-Alarm}" ;;
    list)   list_alarms ;;
    remove) remove_alarm "${2:-}" ;;
    clear)  clear_all ;;
    menu)   rofi_menu ;;
    quick)  quick_timer ;;
    notify) notify "${2:-Alarm}" ;;
    cleanup) cleanup_expired ;;
    -h|--help) usage ;;
    *)      usage ;;
esac
