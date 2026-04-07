# ============================================================================
# GNOME Shell Configuration
# ============================================================================
{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      { package = appindicator; }
      { package = caffeine; }
      {
        id = "user-theme@gnome-shell-extensions.gcampax.github.com";
        package = pkgs.gnome-shell-extensions;
      }
      { package = gamemode-shell-extension; }
      { package = colorblind-filters-advanced; }
    ];
    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-uri = "file:///home/kx/Pictures/barco-de-luffy-1920x1080.jpg";
        picture-uri-dark = "file:///home/kx/Pictures/barco-de-luffy-1920x1080.jpg";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Nordic";
      };
      # Use ghostty as default terminal in GNOME
      "org/gnome/desktop/default-applications/terminal" = {
        exec = "ghostty";
        exec-arg = "";
      };
    };
  };
}
