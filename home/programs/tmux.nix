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

      # move panes with vim splits keybinds
      bind -n C-h swap-pane -L
      bind -n C-j swap-pane -D
      bind -n C-k swap-pane -U
      bind -n C-l swap-pane -R

      # resize keybinds for vim splits
      bind -n S-h select-pane -L
      bind -n S-j select-pane -D
      bind -n S-k select-pane -U
      bind -n S-l select-pane -R
    '';
  };
}
