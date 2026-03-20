# ============================================================================
# Nyxt Browser - Keyboard-driven hacker browser
# ============================================================================
{ config, lib, pkgs, ... }:
{
  home.packages = [ pkgs.nyxt ];

  # Nyxt Configuration File
  xdg.configFile."nyxt/config.lisp".text = ''
    ;; ============================================================================
    ;; Nyxt Configuration - Hacker's Browser
    ;; ============================================================================
    ;; Keyboard schemes: emacs, vi, or cua
    ;; Emacs is recommended for power users, vi for Vim familiarity

    (define-configuration
      ;; ============================================================================
      ;; Keymap Configuration
      ;; ============================================================================
      :keymaps-schemes
      (list
        (make-keymap "emacs-keymap"
          :parent-keymap parent-emacs-keymap)
        (make-keymap "vi-keymap"
          :parent-keymap parent-vi-keymap)
        (make-keymap "cua-keymap"
          :parent-keymap parent-cua-keymap))
      
      :default-keymaps-scheme
      'emacs-keymap)

      ;; ============================================================================
      ;; Search Engine
      ;; ============================================================================
      :default-search-engine
      (make-search-engine
        :name "DuckDuckGo"
        :shortcut "ddg"
        :search-url "https://duckduckgo.com/?q=~a")

      :search-engines
      (list
        (make-search-engine
          :name "Google"
          :shortcut "g"
          :search-url "https://www.google.com/search?q=~a")
        (make-search-engine
          :name "GitHub"
          :shortcut "gh"
          :search-url "https://github.com/search?q=~a")
        (make-search-engine
          :name "NixOS Packages"
          :shortcut "nix"
          :search-url "https://search.nixos.org/options?query=~a")
        (make-search-engine
          :name "YouTube"
          :shortcut "yt"
          :search-url "https://www.youtube.com/results?search_query=~a")
        (make-search-engine
          :name "Wikipedia"
          :shortcut "w"
          :search-url "https://en.wikipedia.org/wiki/Special:Search?search=~a")))

      ;; ============================================================================
      ;; Theme - Nord theme matching your system
      ;; ============================================================================
      :theme
      (make-theme
        :background-color "#2E3440"
        :text-color "#D8DEE9"
        :primary-color "#88C0D0"
        :secondary-color "#81A1C1"
        :tertiary-color "#5E81AC"
        :quaternary-color "#8FBCBB"
        :accent-color "#88C0D0"
        :warning-color "#EBCB8B"
        :danger-color "#BF616A")

      ;; ============================================================================
      ;; UI Settings
      ;; ============================================================================
      :default-new-buffer-url "https://duckduckgo.com"
      :always-show-window-bar nil
      :scroll-step 3
      :smooth-scrolling t

      ;; ============================================================================
      ;; Privacy & Security
      ;; ============================================================================
      :blocklist-mode t
      :enable-cookies t
      :cookies-file (nyxt-file-name "cookies.lisp")

      ;; ============================================================================
      ;; Downloads
      ;; ============================================================================
      :default-download-directory
      (nyxt-path "Downloads")
      :download-lisp-overwrite-confirm t

      ;; ============================================================================
      ;; History
      ;; ============================================================================
      :history-limit 1000
      :history-filename (nyxt-file-name "history.lisp")

      ;; ============================================================================
      ;; Performance
      ;; ============================================================================
      :cache-limit 500)
  '';

  # Desktop entry
  xdg.desktopEntries = [
    {
      name = "Nyxt";
      exec = "nyxt";
      icon = "nyxt";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    }
  ];
}
