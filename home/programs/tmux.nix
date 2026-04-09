# tmux.nix — Módulo Home Manager
# Incluir en tu home.nix o imports
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.bash}/bin/bash"; # Cambia a tu shell (bash, fish, etc.)
    prefix = "C-a";
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
      session-wizard
      vim-tmux-navigator

      yank
      {
        plugin = copy-toolkit;
        extraConfig = ''
          set -g @copytk-copy-command "wl-copy"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];

    extraConfig = ''
      # ─── General ──────────────────────────────────────────────
      set -g extended-keys
      set -g extended-keys-format csi-u
      set-option -g allow-passthrough on

      # Clipboard integration (tmux + wl-clipboard)
      set-option -g set-clipboard on

      # ─── Recargar config ─────────────────────────────────────
      bind r source-file ~/.config/tmux/tmux.conf

      # ─── Sessiones ─────────────────
      bind 0 choose-session
      bind N new-session -c "#{pane_current_path}"

      # ─── Navegación entre paneles (Ctrl + hjkl, sin prefix) ─────────
      # vim-tmux-navigator handles Ctrl+hjkl automatically

      bind -n -r M-n next-window
      bind -n -r M-p previous-window

      bind h select-pane -U 
      bind j select-pane -D 
      bind k select-pane -R 
      bind l select-pane -L 

      # ─── Modo resize (prefix + R → hjkl → Esc) ─────────────────────
      bind R switch-client -T resize
      bind -r -n -T resize h resize-pane -L 5
      bind -r -n -T resize j resize-pane -D 5
      bind -r -n -T resize k resize-pane -U 5
      bind -r -n -T resize l resize-pane -R 5
      bind -r -n -T resize H resize-pane -L 10
      bind -r -n -T resize J resize-pane -D 10
      bind -r -n -T resize K resize-pane -U 10
      bind -r -n -T resize L resize-pane -R 10
      bind -n -T resize Escape switch-client -T root
      bind -n -T resize q switch-client -T root

      # ─── Splits (cómodos en QWERTY ES) ───────────────────────
      unbind '"'
      unbind %
      bind v   split-window -h -c "#{pane_current_path}"
      bind s   split-window -v -c "#{pane_current_path}"

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
      # C-l sin prefix → navegar al panel derecho
      # C-a C-l → clear screen (preservado)
      bind C-l send-keys 'C-l'

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
