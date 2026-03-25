# tmux.nix — Módulo Home Manager
# Incluir en tu home.nix o imports
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.bash}/bin/bash"; # Cambia a tu shell (bash, fish, etc.)
    terminal = "tmux-256color";
    prefix = "M-a";
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 50000;
    disableConfirmationPrompt = true;
    focusEvents = true;
    aggressiveResize = true;
    clock24 = true;
    newSession = true;

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.tmux-which-key;
        extraConfig = ''
          # Enable XDG support to write to home directory instead of Nix store
          set -g @tmux-which-key-xdg-enable 1
          set -g @tmux-which-key-xdg-plugin-path "tmux/plugins/tmux-which-key"
          # Optional: disable autobuild if you prefer manual rebuilds
          set -g @tmux-which-key-disable-autobuild 1
        '';
      }
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.cpu
      tmuxPlugins.copy-toolkit
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];

    extraConfig = ''
      # ─── General ──────────────────────────────────────────────
      set -ag terminal-overrides ",xterm-256color:RGB"
      set  -g extended-keys
      set -g extended-keys-format csi-u
      set-option -g allow-passthrough on


      # ─── Recargar config ─────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config recargada"

      # ─── Sessiones ─────────────────
      bind 0 choose-session
      bind N new-session -c "#{pane_current_path}"

      # ─── Navegación entre paneles (vim hjkl) ─────────────────
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Alt + hjkl sin prefix
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # ─── Splits (cómodos en QWERTY ES) ───────────────────────
      unbind '"'
      unbind %
      bind v   split-window -h -c "#{pane_current_path}"
      bind s   split-window -v -c "#{pane_current_path}"
      bind '\' split-window -h -c "#{pane_current_path}"
      bind '-' split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

      # ─── Redimensionar paneles (HJKL) ────────────────────────
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind -n M-H resize-pane -L 2
      bind -n M-J resize-pane -D 2
      bind -n M-K resize-pane -U 2
      bind -n M-L resize-pane -R 2

      # ─── Navegación entre ventanas ───────────────────────────
      bind -r 1 select-window -t 1
      bind -r 2 select-window -t 2
      bind -r 3 select-window -t 3
      bind -r 4 select-window -t 4
      bind -r 5 select-window -t 5
      bind -r 6 select-window -t 6
      bind -r 7 select-window -t 7
      bind -r 8 select-window -t 8
      bind -r 9 select-window -t 9

      bind -r '<' select-window -p
      bind -r '>' select-window -n
      bind -n -r M-p previous-window
      bind -n -r M-n next-window
      bind 0 choose-window


      # ─── Gestión de paneles ──────────────────────────────────
      bind x   kill-pane
      bind X   kill-window
      bind z   resize-pane -Z
      bind Space   next-layout

      bind -r '{' swap-pane -U
      bind -r '}' swap-pane -D

      # ─── Modo copia (vi-style) ──────────────────────────────
      bind Escape copy-mode
      bind -T copy-mode-vi v      send -X begin-selection
      bind -T copy-mode-vi V      send -X select-line
      bind -T copy-mode-vi C-v    send -X rectangle-toggle
      bind -T copy-mode-vi y      send -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send -X cancel

      bind -T copy-mode-vi '/'    command-prompt -i -p "(buscar abajo)" "send -X search-forward-incremental \"%%%\""
      bind -T copy-mode-vi '?'    command-prompt -i -p "(buscar arriba)" "send -X search-backward-incremental \"%%%\""

      bind p paste-buffer
      bind b choose-buffer

      # ─── Unbind keys ──────────────────────────────────────────
      unbind -n C-l
      # ─── Barra de estado (Nord) ───────────────────────────────
      set -g status-position top
      set -g status-interval 5
      set -g status-justify left

      set -g status-style "bg=#2e3440,fg=#d8dee9"

      # Left: session name + window count
      set -g status-left-length 40
      set -g status-left "#[fg=#2e3440,bg=#81a1c1,bold]  #S #[fg=#81a1c1,bg=#3b4252,nobold]#[fg=#d8dee9,bg=#3b4252] #{session_windows}  #[fg=#3b4252,bg=#2e3440]"

      # Windows: inactive dimmed, active with frost accent
      setw -g window-status-format         "#[fg=#4c566a,bg=#2e3440]  #I #[fg=#4c566a]#W "
      setw -g window-status-current-format "#[fg=#2e3440,bg=#434c5e]#[fg=#88c0d0,bg=#434c5e,bold] #I #[fg=#d8dee9]#W #[fg=#434c5e,bg=#2e3440]"
      setw -g window-status-separator      ""
      setw -g window-status-activity-style "fg=#ebcb8b,bold"
      setw -g window-status-bell-style     "fg=#bf616a,bold"

      # Right: git branch + pane count + date + time + host
      set -g status-right-length 80
      set -g status-right "#[fg=#3b4252,bg=#2e3440]#[fg=#a3be8c,bg=#3b4252]  #{pane_current_command} #[fg=#434c5e,bg=#3b4252]#[fg=#d8dee9,bg=#434c5e] 󰃭 %d/%m #[fg=#4c566a,bg=#434c5e]│#[fg=#ebcb8b] 󰥔 %H:%M #[fg=#81a1c1,bg=#434c5e]#[fg=#2e3440,bg=#81a1c1,bold] #H "

      # Pane borders: thin lines, frost accent on active
      set -g pane-border-lines single
      set -g pane-border-style        "fg=#3b4252"
      set -g pane-active-border-style "fg=#88c0d0"
      set -g pane-border-indicators   colour

      # Messages and command mode
      set -g message-style           "bg=#3b4252,fg=#88c0d0,bold"
      set -g message-command-style   "bg=#3b4252,fg=#ebcb8b"

      # Selection / copy mode
      set -g mode-style "bg=#434c5e,fg=#88c0d0"

      # Clock (prefix + t)
      set -g clock-mode-colour "#81a1c1"

      # Monitor activity
      setw -g monitor-activity on
      set  -g visual-activity off
    '';
  };
}
