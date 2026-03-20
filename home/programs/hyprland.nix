# ============================================================================
# Hyprland Home Manager Configuration
# ============================================================================
{ pkgs, ... }:
{
  # Hyprland-specific user settings
  home.packages = with pkgs; [
    # Terminal - recommended for Hyprland
    kitty

    # Browser
    firefox

    # File manager
    thunar

    # PDF viewer
    evince

    # Image viewer
    imv

    # Media player
    mpv

    # System monitor
    btop

    # Notifications
    dunst

    # Network manager applet
    networkmanagerapplet

    # Bluetooth manager
    blueman

    # Audio control
    pavucontrol

    # Screenshot tools (in addition to grim/slurp)
    flameshot

    # Clipboard manager
    cliphist

    # Color picker
    hyprpicker
  ];

  # Waybar configuration can be managed here with Home Manager
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
          "wlr/taskbar"
        ];

        modules-center = [
          "clock"
        ];

        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "battery"
        ];

        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = true;
          format = "{name}";
          format-icons = {
            urgent = "";
            active = "";
            default = "";
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            format = {
              months = "<span color='#eceff4'><b>{}</b></span>";
              days = "<span color='#eceff4'>{}</span>";
              weeks = "<span color='#81a1c1'>W{}</span>";
              weekdays = "<span color='#88c0d0'>{}</span>";
              today = "<span color='#bf616a'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
          };
        };

        cpu = {
          format = "CPU {usage}%";
          interval = 2;
        };

        memory = {
          format = "RAM {}%";
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [
            "󰈸"
            "󰉃"
            "󰉂"
            "󰉁"
            "󰉀"
          ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󰚥";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          format-time = "{H}h {M}m";
        };

        network = {
          format-wifi = "󰖩  {signalStrength}%";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪";
        };

        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };

    style = ''
      * {
        font-family: 'JetBrains Mono Nerd Font', 'Symbols Nerd Font', monospace;
        font-size: 12px;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        background: rgba(46, 52, 64, 0.95);
        border-bottom: 1px solid rgba(136, 192, 208, 0.3);
        color: #eceff4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #d8dee9;
      }

      #workspaces button.active {
        color: #88c0d0;
      }

      #workspaces button:hover {
        background: rgba(136, 192, 208, 0.2);
      }

      #mode {
        padding: 0 16px;
        background: #bf616a;
      }

      #clock {
        font-weight: bold;
      }

      #cpu, #memory, #temperature, #battery {
        padding: 0 8px;
      }

      #battery.warning {
        color: #ebcb8b;
      }

      #battery.critical {
        color: #bf616a;
      }

      #network {
        padding: 0 8px;
      }

      #pulseaudio {
        padding: 0 8px;
      }

      #tray {
        padding: 0 8px;
      }
    '';
  };

  # Rofi configuration
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = {
      window = {
        transparency = "real";
        background-color = "rgba(46, 52, 64, 0.9)";
        text-color = "#eceff4";
        border = "1px";
        border-color = "#88c0d0";
        border-radius = 8;
      };
      inputbar = {
        children = [
          "prompt"
          "entry"
        ];
        prompt = {
          text-color = "#88c0d0";
        };
        entry = {
          text-color = "#eceff4";
        };
      };
      "element normal" = {
        text-color = "#eceff4";
      };
      "element selected" = {
        text-color = "#2e3440";
        background-color = "#88c0d0";
      };
    };
  };

  # Dunst notifications
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "keyboard";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "16x16";
        frame_width = 2;
        frame_color = "#88c0d0";
        background = "#2e3440";
        foreground = "#eceff4";
        font = "JetBrains Mono 10";
      };
      urgency_normal = {
        background = "#2e3440";
        foreground = "#eceff4";
        frame_color = "#88c0d0";
      };
      urgency_critical = {
        background = "#2e3440";
        foreground = "#bf616a";
        frame_color = "#bf616a";
      };
    };
  };
}
