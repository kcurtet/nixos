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

    plugins = with pkgs.tmuxPlugins; [
      copy-toolkit
      session-wizard
      vim-tmux-navigator
    ];

    extraConfig = ''
      # ─── General ──────────────────────────────────────────────
      set -g extended-keys
      set -g extended-keys-format csi-u
      set-option -g allow-passthrough on


      # ─── Recargar config ─────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config recargada"

      # ─── Sessiones ─────────────────
      bind 0 choose-session
      bind N new-session -c "#{pane_current_path}"

      # ─── Navegación entre paneles (Ctrl + hjkl, sin prefix) ─────────
      # vim-tmux-navigator handles Ctrl+hjkl automatically

      # ─── Mover paneles (Ctrl+Shift + hjkl, sin prefix) ─────────────
      bind -n C-H swap-pane -s '{left-of}'
      bind -n C-J swap-pane -D
      bind -n C-K swap-pane -U
      bind -n C-L swap-pane -s '{right-of}'

      # ─── Navegación entre ventanas (Ctrl + 1-9 / n/p, sin prefix) ──
      bind -n C-1 select-window -t 1
      bind -n C-2 select-window -t 2
      bind -n C-3 select-window -t 3
      bind -n C-4 select-window -t 4
      bind -n C-5 select-window -t 5
      bind -n C-6 select-window -t 6
      bind -n C-7 select-window -t 7
      bind -n C-8 select-window -t 8
      bind -n C-9 select-window -t 9
      bind -n -r C-n next-window
      bind -n -r C-p previous-window

      # ─── Modo resize (prefix + R → hjkl → Esc) ─────────────────────
      bind R switch-client -T resize
      bind -T resize h resize-pane -L 5
      bind -T resize j resize-pane -D 5
      bind -T resize k resize-pane -U 5
      bind -T resize l resize-pane -R 5
      bind -T resize H resize-pane -L 10
      bind -T resize J resize-pane -D 10
      bind -T resize K resize-pane -U 10
      bind -T resize L resize-pane -R 10
      bind -T resize Escape switch-client -T root
      bind -T resize q switch-client -T root

      # ─── Splits (cómodos en QWERTY ES) ───────────────────────
      unbind '"'
      unbind %
      bind v   split-window -h -c "#{pane_current_path}"
      bind s   split-window -v -c "#{pane_current_path}"
      bind '\' split-window -h -c "#{pane_current_path}"
      bind '-' split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

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

      # ─── Barra de estado (Nord + transparencia) ───────────────
      set -g status-position top
      set -g status-interval 5
      set -g status-justify left

      set -g status-style "bg=default,fg=#d8dee9"

      # Left: session name + window count
      set -g status-left-length 40
      set -g status-left "#[fg=#81a1c1,bold] #S #[fg=#4c566a]│#[fg=#d8dee9] #{session_windows} "

      # Windows: inactive dimmed, active with frost accent
      setw -g window-status-format         "#[fg=#4c566a] #I:#W "
      setw -g window-status-current-format "#[fg=#88c0d0,bold] #I:#W #[default]"
      setw -g window-status-separator      "#[fg=#3b4252]│"
      setw -g window-status-activity-style "fg=#ebcb8b,bold"
      setw -g window-status-bell-style     "fg=#bf616a,bold"

      # Right: command + date + time + host
      set -g status-right-length 80
      set -g status-right "#[fg=#4c566a]│#[fg=#a3be8c] #{pane_current_command} #[fg=#4c566a]│#[fg=#ebcb8b] 󰥔 %H:%M #[fg=#4c566a]│#[fg=#81a1c1,bold] #H "

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
