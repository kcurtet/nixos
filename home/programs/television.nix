# ============================================================================
# Television - Fuzzy Finder Configuration
# ============================================================================
{ pkgs, ... }:
let
  flakeDir = "$HOME/system/nixos-config";
  optionsCache = "$HOME/.cache/tv-nix-options";

  syncthingConfig = "/home/kx/syncthing/.config/syncthing/config.xml";

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
      ${pkgs.jq}/bin/jq -r 'keys[] | select(startswith("<") | not)' "$path/share/doc/nixos/options.json" > "$NAMES_FILE"
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

  # Helper script for nix store browsing
  nixStoreHelper = pkgs.writeShellScript "nix-store-helper" ''
    CACHE_DIR="$HOME/.cache/tv-nix-store"
    CACHE_FILE="$CACHE_DIR/paths"

    case "$1" in
      list)
        # Cache for 1 hour
        if [ -f "$CACHE_FILE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE"))) -lt 3600 ]; then
          cat "$CACHE_FILE"
        else
          mkdir -p "$CACHE_DIR"
          nix path-info --all --size 2>/dev/null | ${pkgs.gawk}/bin/awk '{
            size=$2;
            if (size > 1073741824) printf "%.1fG\t%s\n", size/1073741824, $1;
            else if (size > 1048576) printf "%.1fM\t%s\n", size/1048576, $1;
            else if (size > 1024) printf "%.1fK\t%s\n", size/1024, $1;
            else printf "%dB\t%s\n", size, $1;
          }' | sort -t$'\t' -k1 -h -r | tee "$CACHE_FILE"
        fi
        ;;
      show)
        path="$2"
        echo "=== Store Path Info ==="
        nix path-info --size --closure-size "$path" 2>/dev/null | ${pkgs.gawk}/bin/awk '{
          printf "NAR size:     %.1fM\nClosure size: %.1fM\n", $2/1048576, $3/1048576
        }'
        echo ""
        echo "=== Direct References ==="
        nix-store -q --references "$path" 2>/dev/null | sed 's|/nix/store/[a-z0-9]*-||'
        echo ""
        echo "=== Contents (top-level) ==="
        ls "$path" 2>/dev/null
        ;;
      refresh)
        rm -f "$CACHE_DIR/paths"
        echo "Cache cleared. Will rebuild on next list."
        ;;
    esac
  '';

  # Helper for flake inputs
  flakeInputsHelper = pkgs.writeShellScript "flake-inputs-helper" ''
    cd "${flakeDir}" 2>/dev/null || exit 1

    case "$1" in
      list)
        nix flake metadata --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '
          .locks.nodes | to_entries[] |
          select(.value.locked != null) |
          .key + "\t" +
          (if .value.locked.type == "github" then .value.locked.owner + "/" + .value.locked.repo else .value.locked.url // .value.locked.type // "unknown" end) + "\t" +
          (.value.locked.rev // "n/a" | .[0:12]) + "\t" +
          (.value.locked.lastModified // 0 | todate)
        '
        ;;
      show)
        input="$2"
        echo "=== Flake Input: $input ==="
        nix flake metadata --json 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg name "$input" '
          .locks.nodes[$name] // empty |
          "Type:     \(.locked.type // "unknown")" +
          (if .locked.owner then "\nOwner:    \(.locked.owner)" else "" end) +
          (if .locked.repo then "\nRepo:     \(.locked.repo)" else "" end) +
          (if .locked.rev then "\nRev:      \(.locked.rev)" else "" end) +
          (if .locked.lastModified then "\nDate:     \(.locked.lastModified | todate)" else "" end) +
          (if .locked.narHash then "\nHash:     \(.locked.narHash)" else "" end) +
          "\n\n=== Inputs ===" +
          (if .inputs then "\n" + (.inputs | to_entries | map(.key + " -> " + (if (.value | type) == "array" then .value[0] else .value end)) | join("\n")) else "\n(none)" end)
        '
        ;;
    esac
  '';

  # Helper for syncthing
  syncthingHelper = pkgs.writeShellScript "syncthing-helper" ''
    API_KEY=$(${pkgs.gnugrep}/bin/grep -oP '<apikey>\K[^<]+' "${syncthingConfig}" 2>/dev/null)
    if [ -z "$API_KEY" ]; then
      echo "Cannot read Syncthing API key"
      exit 1
    fi
    api() {
      ${pkgs.curl}/bin/curl -sf -H "X-API-Key: $API_KEY" "http://127.0.0.1:8384$1" 2>/dev/null
    }

    case "$1" in
      list)
        api "/rest/config/folders" | ${pkgs.jq}/bin/jq -r '.[] | .label + "\t" + .id + "\t" + .path'
        if [ $? -ne 0 ]; then echo "(syncthing not responding)"; fi
        ;;
      show)
        folder_label="$2"
        folder_id=$(api "/rest/config/folders" | ${pkgs.jq}/bin/jq -r --arg l "$folder_label" '.[] | select(.label == ($l | split("\t")[0])) | .id')
        if [ -z "$folder_id" ]; then
          echo "Folder not found"
          exit 1
        fi

        echo "=== Folder: $folder_label ==="
        api "/rest/config/folders" | ${pkgs.jq}/bin/jq -r --arg id "$folder_id" '
          .[] | select(.id == $id) |
          "ID:       \(.id)\nPath:     \(.path)\nType:     \(.type)\nIgnore:   \(.ignorePerms)\nWatch:    \(.fsWatcherEnabled)"
        '
        echo ""
        echo "=== Sync Status ==="
        api "/rest/db/status?folder=$folder_id" | ${pkgs.jq}/bin/jq -r '
          "State:       \(.state)\nFiles:       \(.localFiles)/\(.globalFiles)\nBytes:       \(.inSyncBytes)/\(.globalBytes)\nNeed files:  \(.needFiles)\nNeed bytes:  \(.needBytes)"
        '
        echo ""
        echo "=== Connected Devices ==="
        api "/rest/config/folders" | ${pkgs.jq}/bin/jq -r --arg id "$folder_id" '
          .[] | select(.id == $id) | .devices[].deviceID[:12]
        '
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

      nix-store = {
        metadata = {
          name = "nix-store";
          description = "Browse Nix store paths by size";
          requirements = [ "nix" ];
        };
        source = {
          command = "${nixStoreHelper} list";
        };
        preview = {
          command = "${nixStoreHelper} show '{split:\\t:1}'";
        };
        ui = {
          preview_panel = {
            size = 55;
          };
        };
        keybindings = {
          ctrl-d = "actions:delete";
          ctrl-r = "actions:refresh";
        };
        actions = {
          delete = {
            description = "Delete store path (requires sudo)";
            command = "sudo nix store delete '{split:\\t:1}'";
            mode = "fork";
          };
          refresh = {
            description = "Refresh cache";
            command = "${nixStoreHelper} refresh";
            mode = "fork";
          };
        };
      };

      nix-flake-inputs = {
        metadata = {
          name = "nix-flake-inputs";
          description = "Browse and update flake inputs";
          requirements = [
            "nix"
            "jq"
          ];
        };
        source = {
          command = "${flakeInputsHelper} list";
        };
        preview = {
          command = "${flakeInputsHelper} show '{split:\\t:0}'";
        };
        ui = {
          preview_panel = {
            size = 55;
          };
        };
        keybindings = {
          ctrl-u = "actions:update";
          ctrl-o = "actions:open";
        };
        actions = {
          update = {
            description = "Update this input";
            command = "cd ${flakeDir} && nix flake update '{split:\\t:0}'";
            mode = "fork";
          };
          open = {
            description = "Open on GitHub";
            command = "xdg-open 'https://github.com/{split:\\t:1}'";
            mode = "fork";
          };
        };
      };

      ollama-models = {
        metadata = {
          name = "ollama-models";
          description = "Browse and manage Ollama models";
          requirements = [ "ollama" ];
        };
        source = {
          command = "ollama list | tail -n +2";
        };
        preview = {
          command = "ollama show '{split: :0}'";
        };
        ui = {
          preview_panel = {
            size = 60;
          };
        };
        keybindings = {
          ctrl-d = "actions:delete";
          ctrl-r = "actions:run";
        };
        actions = {
          delete = {
            description = "Delete model";
            command = "ollama rm '{split: :0}'";
            mode = "fork";
          };
          run = {
            description = "Run model interactively";
            command = "ollama run '{split: :0}'";
            mode = "fork";
          };
        };
      };

      hcloud-servers = {
        metadata = {
          name = "hcloud-servers";
          description = "Browse and manage Hetzner Cloud servers";
          requirements = [ "hcloud" ];
        };
        source = {
          command = "hcloud server list -o 'columns=name,status,server_type,ipv4,datacenter'";
        };
        preview = {
          command = "hcloud server describe '{split: :0}' -o yaml";
        };
        ui = {
          preview_panel = {
            size = 60;
          };
        };
        keybindings = {
          ctrl-s = "actions:ssh";
          ctrl-p = "actions:power";
          ctrl-r = "actions:reboot";
        };
        actions = {
          ssh = {
            description = "SSH into server";
            command = "ssh root@$(hcloud server ip '{split: :0}')";
            mode = "execute";
          };
          power = {
            description = "Toggle power (on if off, off if on)";
            command = "status=$(hcloud server describe '{split: :0}' -o json | jq -r .status); if [ \"$status\" = \"running\" ]; then hcloud server poweroff '{split: :0}'; else hcloud server poweron '{split: :0}'; fi";
            mode = "fork";
          };
          reboot = {
            description = "Reboot server";
            command = "hcloud server reboot '{split: :0}'";
            mode = "fork";
          };
        };
      };

      syncthing-folders = {
        metadata = {
          name = "syncthing-folders";
          description = "Browse Syncthing shared folders and sync status";
          requirements = [
            "curl"
            "jq"
          ];
        };
        source = {
          command = "${syncthingHelper} list";
        };
        preview = {
          command = "${syncthingHelper} show '{split:\\t:0}'";
        };
        ui = {
          preview_panel = {
            size = 55;
          };
        };
        keybindings = {
          ctrl-o = "actions:open";
          ctrl-b = "actions:browse";
        };
        actions = {
          open = {
            description = "Open folder in file manager";
            command = "xdg-open '{split:\\t:2}'";
            mode = "fork";
          };
          browse = {
            description = "Open Syncthing web UI";
            command = "xdg-open 'http://localhost:8384'";
            mode = "fork";
          };
        };
      };

      nixos-config = {
        metadata = {
          name = "nixos-config";
          description = "Browse NixOS configuration files";
          requirements = [
            "fd"
            "bat"
          ];
        };
        source = {
          command = "fd -t f -e nix . ${flakeDir} --strip-cwd-prefix";
        };
        preview = {
          command = "bat -n --color=always '{}'";
        };
        ui = {
          preview_panel = {
            size = 65;
          };
        };
        keybindings = {
          ctrl-e = "actions:edit";
        };
        actions = {
          edit = {
            description = "Open in neovim";
            command = "nvim '{}'";
            mode = "execute";
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
