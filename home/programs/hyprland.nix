# ============================================================================
# Hyprland Home Manager Configuration
# ============================================================================
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hyprland;
in
{
  options.programs.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
  };

  config = lib.mkIf cfg.enable {
    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$mod" = "SUPER";

        # Monitor setup
        monitor = ",preferred,auto,1";

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(81a1c1ee) rgba(88c0d0ee) 45deg";
          "col.inactive_border" = "rgba(4c566a80)";
          layout = "dwindle";
        };

        # Decoration
        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 2;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
        };

        # Input
        input = {
          kb_layout = "es";
          kb_variant = "cat";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            tap-to-click = true;
          };
        };

        # Keybinds
        bind = [
          # Terminal
          "$mod, Return, exec, foot"

          # App launcher
          "$mod, D, exec, rofi -show drun -show-icons"

          # Close window
          "$mod, Q, killactive"

          # Fullscreen
          "$mod, F, fullscreen"

          # Toggle floating
          "$mod, Space, togglefloating"

          # Focus movement
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move window
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Resize
          "$mod CTRL, left, resizeactive, -20 0"
          "$mod CTRL, right, resizeactive, 20 0"
          "$mod CTRL, up, resizeactive, 0 -20"
          "$mod CTRL, down, resizeactive, 0 20"

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Volume
          ", XF86AudioRaiseVolume, exec, pamixer --increase 5"
          ", XF86AudioLowerVolume, exec, pamixer --decrease 5"
          ", XF86AudioMute, exec, pamixer --toggle"
          ", XF86AudioMicMute, exec, pamixer --default-source --toggle"

          # Brightness
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # Media
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"

          # Screenshot
          "$mod, S, exec, grim -g \"$(slurp)\" - | wl-copy"

          # Exit Hyprland
          "$mod SHIFT, E, exit"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Window rules
        windowrulev2 = [
          "float, class:^(pavucontrol)$"
          "float, class:^(nm-connection-editor)$"
          "float, class:^(blueman-manager)$"
          "size 50% 50%, class:^(pavucontrol)$"
          "center, class:^(pavucontrol)$"
        ];

        # Startup apps
        exec-once = [
          "waybar"
          "dunst"
          "swww-daemon"
          "hyprpaper"
        ];
      };

      # Extra config for wallpaper
      extraConfig = ''
        $wallpaper = ~/.config/wallpaper.png
      '';
    };

    # Waybar configuration
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 36;
          modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "clock"
            "tray"
          ];

          "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "10";
            };
          };

          clock = {
            format = "{:%H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          cpu = {
            format = "CPU {usage}%";
            tooltip = false;
          };

          memory = {
            format = "MEM {}%";
            tooltip = false;
          };

          temperature = {
            critical-threshold = 80;
            format = "{icon} {temperatureC}°C";
            format-icons = ["󱃃" "󰔏" "󰸁" "󱃂"];
          };

          network = {
            format-wifi = "󰖩 {signalStrength}%";
            format-ethernet = "󰈀 {ipaddr}";
            format-linked = "󰖪 {ipaddr}";
            format-disconnected = "󰖪";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = "󰝟";
            format-icons = {
              default = ["󰕿" "󰖀" "󰕾"];
            };
            on-click = "pavucontrol";
          };
        };
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 13px;
          min-height: 0;
          margin: 0;
          padding: 0;
        }

        window#waybar {
          background: rgba(46, 52, 64, 0.95);
          border-bottom: 2px solid rgba(129, 161, 193, 0.5);
        }

        #workspaces button {
          padding: 0 10px;
          color: #d8dee9;
          background: transparent;
        }

        #workspaces button.active {
          color: #88c0d0;
          background: rgba(136, 192, 208, 0.2);
        }

        #workspaces button:hover {
          background: rgba(129, 161, 193, 0.2);
        }

        #clock, #cpu, #memory, #temperature, #network, #pulseaudio, #tray {
          padding: 0 10px;
          color: #d8dee9;
        }
      '';
    };

    # Foot terminal configuration
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=11";
          dpi-aware = "yes";
        };

        colors = {
          background = "2e3440";
          foreground = "d8dee9";
          regular0 = "3b4252";
          regular1 = "bf616a";
          regular2 = "a3be8c";
          regular3 = "ebcb8b";
          regular4 = "81a1c1";
          regular5 = "b48ead";
          regular6 = "88c0d0";
          regular7 = "e5e9f0";
          bright0 = "4c566a";
          bright1 = "bf616a";
          bright2 = "a3be8c";
          bright3 = "ebcb8b";
          bright4 = "81a1c1";
          bright5 = "b48ead";
          bright6 = "8fbcbb";
          bright7 = "eceff4";
        };
      };
    };

    # Rofi configuration
    programs.rofi = {
      enable = true;
      pass = {
        enable = true;
        stores = [ "password-store" ];
      };
      theme = "Nord";
    };

    # Dunst notification configuration
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 11";
          frame_color = "#81a1c1";
          separator_color = "#4c566a";
        };
        urgency_low = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_normal = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        urgency_critical = {
          background = "#bf616a";
          foreground = "#eceff4";
        };
      };
    };

    # User packages
    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      cliphist
      pamixer
      brightnessctl
      playerctl
    ];
  };
}
