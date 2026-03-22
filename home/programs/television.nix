# ============================================================================
# Television - Fuzzy Finder Configuration
# ============================================================================
{ pkgs, ... }:
let
  flakeDir = "$HOME/system/nixos-config";
  optionsCache = "$HOME/.cache/tv-nix-options";

  # Helper script that builds/caches the options.json store path
  nixOptionsHelper = pkgs.writeShellScript "nix-options-helper" ''
    CACHE_DIR="${optionsCache}"
    CACHE_FILE="$CACHE_DIR/options-path"
    NAMES_FILE="$CACHE_DIR/option-names"

    ensure_cache() {
      if [ -f "$NAMES_FILE" ] && [ -f "$CACHE_FILE" ]; then
        local stored
        stored=$(cat "$CACHE_FILE")
        if [ -d "$stored" ]; then
          return 0
        fi
      fi
      mkdir -p "$CACHE_DIR"
      local path
      path=$(nix build "${flakeDir}#nixosConfigurations.panther.config.system.build.manual.optionsJSON" \
        --no-link --print-out-paths 2>/dev/null)
      if [ -z "$path" ]; then
        echo "Failed to build options.json" >&2
        return 1
      fi
      echo "$path" > "$CACHE_FILE"
      ${pkgs.jq}/bin/jq -r 'keys[]' "$path/share/doc/nixos/options.json" > "$NAMES_FILE"
    }

    case "$1" in
      list)
        ensure_cache && cat "$NAMES_FILE"
        ;;
      show)
        ensure_cache || exit 1
        local path
        path=$(cat "$CACHE_FILE")
        ${pkgs.jq}/bin/jq -r --arg opt "$2" '
          .[$opt] //empty |
          "Type: \(.type)\n" +
          (if .default != null then
            "Default: " + (if (.default | type) == "object" and .default._type == "literalExpression" then .default.text else (.default | tostring) end) + "\n"
           else "" end) +
          (if .example != null then
            "\nExample:\n" + (if (.example | type) == "object" and .example._type == "literalExpression" then .example.text else (.example | tostring) end) + "\n"
           else "" end) +
          "\nDescription:\n\(.description)" +
          "\n\nDeclared by:\n\(.declarations | join("\n"))"
        ' "$path/share/doc/nixos/options.json"
        ;;
      refresh)
        rm -rf "$CACHE_DIR"
        ensure_cache && echo "Cache refreshed: $(wc -l < "$NAMES_FILE") options"
        ;;
    esac
  '';
in
{
  programs.television = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      tick_rate = 50;
      default_channel = "files";
      history_size = 200;
      global_history = false;

      ui = {
        ui_scale = 100;
        orientation = "landscape";
        theme = "default";

        input_bar = {
          position = "top";
          prompt = ">";
          border_type = "rounded";
        };

        status_bar = {
          separator_open = "";
          separator_close = "";
          hidden = false;
        };

        results_panel = {
          border_type = "rounded";
        };

        preview_panel = {
          size = 50;
          scrollbar = true;
          border_type = "rounded";
          hidden = false;
        };

        help_panel = {
          show_categories = true;
          hidden = true;
        };

        remote_control = {
          show_channel_descriptions = true;
          sort_alphabetically = true;
        };
      };

      keybindings = {
        # Application control
        esc = "quit";
        ctrl-c = "quit";

        # Navigation
        down = "select_next_entry";
        ctrl-n = "select_next_entry";
        ctrl-j = "select_next_entry";
        up = "select_prev_entry";
        ctrl-p = "select_prev_entry";
        ctrl-k = "select_prev_entry";

        # History
        ctrl-up = "select_prev_history";
        ctrl-down = "select_next_history";

        # Selection
        tab = "toggle_selection_down";
        backtab = "toggle_selection_up";
        enter = "confirm_selection";

        # Preview
        pagedown = "scroll_preview_half_page_down";
        pageup = "scroll_preview_half_page_up";
        ctrl-f = "cycle_previews";

        # Data operations
        ctrl-y = "copy_entry_to_clipboard";
        ctrl-r = "reload_source";
        ctrl-s = "cycle_sources";

        # UI toggles
        ctrl-t = "toggle_remote_control";
        ctrl-x = "toggle_action_picker";
        ctrl-o = "toggle_preview";
        ctrl-h = "toggle_help";
        f12 = "toggle_status_bar";
        ctrl-l = "toggle_layout";

        # Input field
        backspace = "delete_prev_char";
        ctrl-w = "delete_prev_word";
        ctrl-u = "delete_line";
        delete = "delete_next_char";
        left = "go_to_prev_char";
        right = "go_to_next_char";
        home = "go_to_input_start";
        ctrl-a = "go_to_input_start";
        end = "go_to_input_end";
        ctrl-e = "go_to_input_end";
      };

      shell_integration = {
        fallback_channel = "files";
        channel_triggers = {
          "alias" = [
            "alias"
            "unalias"
          ];
          "env" = [
            "export"
            "unset"
          ];
          "dirs" = [
            "cd"
            "ls"
            "rmdir"
            "z"
          ];
          "files" = [
            "cat"
            "less"
            "head"
            "tail"
            "vim"
            "nano"
            "bat"
            "cp"
            "mv"
            "rm"
            "touch"
            "chmod"
            "chown"
            "ln"
            "tar"
            "zip"
            "unzip"
            "gzip"
            "gunzip"
            "xz"
          ];
          "git-diff" = [
            "git add"
            "git restore"
          ];
          "git-branch" = [
            "git checkout"
            "git branch"
            "git merge"
            "git rebase"
            "git pull"
            "git push"
          ];
          "git-log" = [
            "git log"
            "git show"
          ];
          "docker-images" = [ "docker run" ];
          "git-repos" = [
            "nvim"
            "code"
            "hx"
            "git clone"
          ];
        };

        keybindings = {
          smart_autocomplete = "ctrl-t";
          command_history = "ctrl-r";
        };
      };
    };

    channels = {
      nix-options = {
        metadata = {
          name = "nix-options";
          description = "Browse NixOS and Home Manager options";
          requirements = [
            "nix"
            "jq"
          ];
        };
        source = {
          command = "${nixOptionsHelper} list";
        };
        preview = {
          command = "${nixOptionsHelper} show '{}'";
        };
        ui = {
          preview_panel = {
            size = 65;
          };
        };
        keybindings = {
          ctrl-r = "actions:refresh";
          ctrl-o = "actions:open-search";
        };
        actions = {
          refresh = {
            description = "Rebuild options cache";
            command = "${nixOptionsHelper} refresh";
            mode = "fork";
          };
          open-search = {
            description = "Open on search.nixos.org";
            command = "xdg-open 'https://search.nixos.org/options?query={}'";
            mode = "fork";
          };
        };
      };

      nixos-generations = {
        metadata = {
          name = "nixos-generations";
          description = "Browse NixOS generations with package diffs";
          requirements = [ "nixos-rebuild" ];
        };
        source = {
          command = "nixos-rebuild list-generations | tail -n +2";
        };
        preview = {
          command = "gen=$(echo '{}' | awk '{print $1}'); prev=$((gen - 1)); nix store diff-closures /nix/var/nix/profiles/system-\${prev}-link /nix/var/nix/profiles/system-\${gen}-link 2>/dev/null || echo 'No previous generation to diff against'";
        };
        ui = {
          preview_panel = {
            size = 65;
          };
        };
        keybindings = {
          ctrl-s = "actions:switch";
          ctrl-d = "actions:delete";
        };
        actions = {
          switch = {
            description = "Switch to this generation (requires sudo)";
            command = "gen=$(echo '{}' | awk '{print $1}'); sudo nix-env --switch-generation $gen -p /nix/var/nix/profiles/system && sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch";
            mode = "fork";
          };
          delete = {
            description = "Delete this generation (requires sudo)";
            command = "gen=$(echo '{}' | awk '{print $1}'); sudo nix-env --delete-generations $gen -p /nix/var/nix/profiles/system";
            mode = "fork";
          };
        };
      };
    };
  };
}
