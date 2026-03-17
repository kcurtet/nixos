# ============================================================================
# Tmux Configuration
# ============================================================================
{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "M-a";
    disableConfirmationPrompt = true;
    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";
    aggressiveResize = true;
    escapeTime = 0;
    focusEvents = true;
    historyLimit = 10000;
    mouse = true;
    terminal = "screen-256color";
    resizeAmount = 10;
    clock24 = true;
    customPaneNavigationAndResize = true;
    baseIndex = 1;
    newSession = true;

    plugins = with pkgs; [
      tmuxPlugins.cpu
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
      set -g extended-keys on
      set -g extended-keys-format csi-u

      # navigate between vim splits and tmux panes seamlessly
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # move/swap panes with ctrl+vim keys
      bind -n C-M-h swap-pane -s '{left-of}'
      bind -n C-M-j swap-pane -s '{down-of}'
      bind -n C-M-k swap-pane -s '{up-of}'
      bind -n C-M-l swap-pane -s '{right-of}'

      # resize panes with prefix + vim keys (held)
      bind -r h resize-pane -L 5
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
    '';
  };
}
