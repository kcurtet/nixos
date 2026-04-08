#!/usr/bin/env bash
# Show all Hyprland keybinds grouped by section in rofi

awk '
# Track current section from "# ── Section ──" headers
/^# ── .+ ──/ {
    match($0, /# ── (.+) ──/, m)
    section = m[1]
    next
}

# Match bind lines
/^bind/ {
    # Extract: modifier, key, dispatcher, arg
    line = $0
    sub(/^bind[a-z]* *= */, "", line)
    split(line, parts, ", *")

    mod = parts[1]; key = parts[2]; dispatcher = parts[3]; arg = parts[4]

    # Prettify modifier
    gsub(/\$mod\+SHIFT/, "Super+Shift", mod)
    gsub(/\$mod ALT/, "Super+Alt", mod)
    gsub(/\$mod/, "Super", mod)
    if (mod == "") mod = " "

    # Build description from dispatcher + arg
    desc = ""
    if (dispatcher == "exec") {
        # Derive description from the command
        cmd = arg
        if (cmd ~ /alacritty/)      desc = "Open terminal"
        else if (cmd ~ /rofi/)      desc = "App launcher"
        else if (cmd ~ /thunar/)    desc = "File manager"
        else if (cmd ~ /brave/)     desc = "Web browser"
        else if (cmd ~ /hyprctl kill/) desc = "Pick & kill window"
        else if (cmd ~ /swaylock/)  desc = "Lock screen"
        else if (cmd ~ /hyprpicker/) desc = "Color picker"
        else if (cmd ~ /wlogout/)   desc = "Logout menu"
        else if (cmd ~ /keybinds/)  desc = "Show keybinds"
        else if (cmd ~ /slurp.*wl-copy/) desc = "Screenshot region → clipboard"
        else if (cmd ~ /grim.*wl-copy/)  desc = "Screenshot full → clipboard"
        else if (cmd ~ /grim/)      desc = "Screenshot → file"
        else if (cmd ~ /pamixer --increase/) desc = "Volume up"
        else if (cmd ~ /pamixer --decrease/) desc = "Volume down"
        else if (cmd ~ /pamixer --toggle/)   desc = "Toggle mute"
        else if (cmd ~ /pamixer.*--default-source/) desc = "Toggle mic mute"
        else if (cmd ~ /brightnessctl.*\+/) desc = "Brightness up"
        else if (cmd ~ /brightnessctl.*-/)  desc = "Brightness down"
        else if (cmd ~ /playerctl play/)    desc = "Play / Pause"
        else if (cmd ~ /playerctl next/)    desc = "Next track"
        else if (cmd ~ /playerctl prev/)    desc = "Previous track"
        else desc = cmd
    }
    else if (dispatcher == "killactive")          desc = "Close window"
    else if (dispatcher == "fullscreen" && arg == "1") desc = "Maximize toggle"
    else if (dispatcher == "fullscreen" && arg == "0") desc = "True fullscreen"
    else if (dispatcher == "togglefloating")       desc = "Toggle floating"
    else if (dispatcher == "togglesplit")          desc = "Toggle split"
    else if (dispatcher == "pseudo")               desc = "Pseudo-tile"
    else if (dispatcher == "togglegroup")          desc = "Toggle group"
    else if (dispatcher == "movefocus")            desc = "Focus " arg
    else if (dispatcher == "movewindow")           desc = "Move window " arg
    else if (dispatcher == "resizeactive")         desc = "Resize window"
    else if (dispatcher == "workspace" && arg ~ /^[0-9]+$/) desc = "Go to workspace " arg
    else if (dispatcher == "workspace" && arg == "e+1")     desc = "Next workspace"
    else if (dispatcher == "workspace" && arg == "e-1")     desc = "Previous workspace"
    else if (dispatcher == "workspace" && arg == "previous") desc = "Last workspace"
    else if (dispatcher == "movetoworkspace" && arg ~ /^[0-9]+$/) desc = "Move to workspace " arg
    else if (dispatcher == "movetoworkspace" && arg ~ /special/) desc = "Move to scratchpad"
    else if (dispatcher == "togglespecialworkspace") desc = "Toggle scratchpad"
    else if (dispatcher == "movewindow")           desc = "Move window (mouse)"
    else if (dispatcher == "resizewindow")         desc = "Resize window (mouse)"
    else desc = dispatcher " " arg

    # Print: section | keys | description
    printf "%-20s  %-22s  %s\n", section, mod " + " key, desc
}
' ~/.config/hypr/hyprland.conf | rofi -dmenu -i -p " Keybinds" -theme ~/.config/rofi/nord.rasi -theme-str 'window {width: 60%;} listview {lines: 25;}'
