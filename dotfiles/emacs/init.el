;; -*- lexical-binding: t; -*-
;; ============================================================================
;; Init.el — Minimal Emacs Configuration (Nord Theme)
;; ============================================================================

;; ── Package management (straight.el) ───────────────────────────────────────
;; straight.el is bootstrapped in early-init.el
(straight-use-package 'use-package)

;; Configure use-package to use straight.el
(require 'use-package)
(setq use-package-always-ensure t
      straight-use-package-by-default t)

;; ── Shell Environment (Nix paths) ──────────────────────────────────────────
(use-package exec-path-from-shell
  :demand t
  :config
  (setq exec-path-from-shell-arguments '("-l"))  ; login shell for full env
  (exec-path-from-shell-initialize)
  ;; Import additional Nix-related env vars
  (dolist (var '("NIX_PATH" "NIX_SSL_CERT_FILE" "LOCALE_ARCHIVE"))
    (exec-path-from-shell-copy-env var)))

;; ── Defaults ───────────────────────────────────────────────────────────────
(setq-default
 indent-tabs-mode nil
 tab-width 4
 fill-column 80
 sentence-end-double-space nil
 require-final-newline t)

(setq
 inhibit-startup-screen t
 inhibit-startup-message t
 initial-scratch-message nil
 ring-bell-function 'ignore
 use-short-answers t
 confirm-kill-emacs 'y-or-n-p
 make-backup-files nil
 auto-save-default nil
 create-lockfiles nil
 custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Load custom file if it exists (keeps init.el clean)
(when (file-exists-p custom-file) (load custom-file))

;; UTF-8 everywhere
(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)

;; ── UI ─────────────────────────────────────────────────────────────────────
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-hl-line-mode 1)
(pixel-scroll-precision-mode 1)

;; Frame transparency (85% opacity - slightly higher for readability)
(set-frame-parameter nil 'alpha-background 85)
(add-to-list 'default-frame-alist '(alpha-background . 85))

;; Prettier UI elements
(setq-default
 cursor-type '(bar . 2)                    ; Thicker bar cursor
 cursor-in-non-selected-windows 'hollow    ; Hollow cursor in inactive windows
 window-resize-pixelwise t                 ; Pixel-perfect window resizing
 frame-resize-pixelwise t)

;; Nerd Icons (required for doom-modeline, treemacs, etc.)
(use-package nerd-icons
  :demand t)

;; Beautiful modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 30
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-enable-word-count t
        doom-modeline-minor-modes nil
        doom-modeline-display-default-persp-name t
        doom-modeline-lsp t
        doom-modeline-github nil
        doom-modeline-modal-icon t
        doom-modeline-mu4e nil
        doom-modeline-irc nil
        doom-modeline-time nil
        doom-modeline-vcs-max-length 30))

;; Dashboard
(use-package dashboard
  :init
  (setq dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-startup-banner 'logo
        dashboard-banner-logo-title "EMACS"
        dashboard-icon-type 'nerd-icons
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-set-init-info t
        dashboard-items '((recents   . 5)
                          (bookmarks . 5)
                          (projects  . 5))
        dashboard-navigator-buttons
        `(;; Line 1
          ((,(nerd-icons-mdicon "nf-md-github" :face 'nerd-icons-blue)
            "GitHub"
            "Browse homepage"
            (lambda (&rest _) (browse-url "https://github.com")))
           (,(nerd-icons-mdicon "nf-md-file_document" :face 'nerd-icons-green)
            "Config"
            "Open config"
            (lambda (&rest _) (find-file user-init-file))))))
  :config
  (dashboard-setup-startup-hook))

;; Rainbow delimiters - colorful parentheses
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Indentation guides
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?│
        highlight-indent-guides-responsive 'top
        highlight-indent-guides-delay 0))

;; Pulsing cursor on window change
(use-package pulsar
  :init (pulsar-global-mode 1)
  :config
  (setq pulsar-pulse t
        pulsar-delay 0.055
        pulsar-iterations 10
        pulsar-face 'pulsar-green)
  (dolist (cmd '(other-window
                 evil-window-left evil-window-right evil-window-up evil-window-down
                 split-window-below split-window-right delete-window))
    (add-to-list 'pulsar-pulse-functions cmd)))

;; Disable line numbers in some modes
(dolist (mode '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                vterm-mode-hook
                dashboard-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Font
(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 140
                    :weight 'medium)

;; ── Theme (Nord) ───────────────────────────────────────────────────────────
(use-package nord-theme
  :config
  (setq nord-comment-brightness 15
        nord-region-highlight 'snowstorm)
  (load-theme 'nord t)

  ;; Custom face tweaks for better aesthetics
  (with-eval-after-load 'nord-theme
    (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
    (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
    (set-face-attribute 'font-lock-string-face nil :slant 'italic)
    (set-face-attribute 'line-number-current-line nil :weight 'bold)
    (set-face-attribute 'show-paren-match nil :weight 'ultra-bold :underline t)
    (set-face-attribute 'vertical-border nil :foreground "#3b4252")
    (set-face-attribute 'fringe nil :background nil)))

;; Beacon - highlight cursor on scroll/jump
(use-package beacon
  :init (beacon-mode 1)
  :config
  (setq beacon-size 40
        beacon-blink-when-point-moves-horizontally nil
        beacon-blink-when-point-moves-vertically 10
        beacon-color "#88c0d0"))

;; ── Completion (Vertico + Orderless + Marginalia) ──────────────────────────
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-g g" . consult-goto-line)
         ("M-s r" . consult-ripgrep)
         ("C-x f" . consult-fd))
  :config
  ;; Use fd for file finding
  (setq consult-fd-args '("fd" "--full-path" "--color=never" "--hidden" "--exclude" ".git")))

;; ── In-Buffer Completion (Corfu) ────────────────────────────────────────────
(use-package corfu
  :init
  (global-corfu-mode)
  :config
  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-preview-current nil))

;; Add extensions (cape) to completion-at-point
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; ── Which Key ──────────────────────────────────────────────────────────────
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3
        which-key-idle-secondary-delay 0.05
        which-key-sort-order 'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns 4
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-allow-imprecise-window-fit nil
        which-key-separator " → "))

;; ── Treemacs (File Tree) ────────────────────────────────────────────────────
(use-package treemacs
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil " ↘ " " ↘")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-ignoring-case
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           'none
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (treemacs-git-mode 'deferred))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-nerd-icons
  :after (treemacs nerd-icons)
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :after (treemacs magit))

;; ── Vim Keybindings (Evil) ─────────────────────────────────────────────────
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-undo-system 'undo-redo
        evil-search-module 'evil-search)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode))

;; ── Keybindings (general.el) ───────────────────────────────────────────────
(use-package general
  :config
  (general-evil-setup t)

  ;; Leader key (SPC)
  (general-create-definer leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC")

  (leader
    ""   '(:ignore t :which-key "leader")

    ;; Files
    "f"  '(:ignore t :which-key "files")
    "ff" '(consult-fd :which-key "find file")
    "fr" '(consult-recent-file :which-key "recent files")
    "fs" '(save-buffer :which-key "save")
    "fS" '(save-some-buffers :which-key "save all")
    "fR" '(rename-file :which-key "rename")
    "fD" '(delete-file :which-key "delete")
    "fy" '((lambda () (interactive) (kill-new (buffer-file-name))) :which-key "yank path")
    "fe" '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :which-key "edit init.el")
    "ft" '(treemacs :which-key "treemacs")

    ;; Buffers
    "b"  '(:ignore t :which-key "buffers")
    "bb" '(consult-buffer :which-key "switch buffer")
    "bk" '(kill-buffer :which-key "kill buffer")
    "bd" '(kill-this-buffer :which-key "kill (current) buffer")
    "bn" '(next-buffer :which-key "next")
    "bp" '(previous-buffer :which-key "prev")
    "bs" '(save-buffer :which-key "save")
    "bS" '(save-some-buffers :which-key "save all")
    "br" '(revert-buffer :which-key "revert")
    "bi" '(ibuffer :which-key "ibuffer")
    "bm" '(bookmark-set :which-key "set bookmark")
    "bM" '(bookmark-jump :which-key "jump bookmark")

    ;; Windows
    "w"  '(:ignore t :which-key "windows")
    "ww" '(other-window :which-key "other")
    "wd" '(delete-window :which-key "delete")
    "wD" '(delete-other-windows :which-key "delete others")
    "ws" '(split-window-below :which-key "split below")
    "wv" '(split-window-right :which-key "split right")
    "wh" '(evil-window-left :which-key "left")
    "wj" '(evil-window-down :which-key "down")
    "wk" '(evil-window-up :which-key "up")
    "wl" '(evil-window-right :which-key "right")

    ;; Edit
    "e"  '(:ignore t :which-key "edit")
    "ed" '((lambda () (interactive) (let ((line (thing-at-point 'line t))) (end-of-line) (insert "\n" line))) :which-key "duplicate line")
    "ek" '(kill-whole-line :which-key "kill line")
    "eJ" '(join-line :which-key "join line")
    "eu" '(vundo :which-key "undo tree")
    "er" '(replace-string :which-key "replace")
    "eR" '(query-replace :which-key "query replace")

    ;; Registers
    "r"  '(:ignore t :which-key "registers")
    "ry" '(copy-to-register :which-key "copy to reg")
    "rp" '(insert-register :which-key "paste from reg")
    "rj" '(jump-to-register :which-key "jump to reg")

    ;; Toggle
    "T"  '(:ignore t :which-key "toggle")
    "Tt" '(treemacs :which-key "treemacs")
    "Tn" '(display-line-numbers-mode :which-key "line numbers")
    "Tw" '(whitespace-mode :which-key "whitespace")
    "Tf" '(auto-fill-mode :which-key "auto fill")
    "Ts" '(flymake-mode :which-key "flymake")
    "Tm" '(toggle-frame-maximized :which-key "maximize")
    "TF" '(toggle-frame-fullscreen :which-key "fullscreen")

    ;; Errors
    "x"  '(:ignore t :which-key "errors")
    "xn" '(next-error :which-key "next error")
    "xp" '(previous-error :which-key "prev error")
    "xl" '(flymake-show-buffer-diagnostics :which-key "list errors")

    ;; Bookmarks
    "m"  '(:ignore t :which-key "bookmarks")
    "mm" '(bookmark-set :which-key "set")
    "mj" '(bookmark-jump :which-key "jump")
    "ml" '(list-bookmarks :which-key "list")

    ;; Git
    "g"  '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "magit")

    ;; Projects
    "p"  '(:ignore t :which-key "projects")
    "pp" '(consult-projectile-switch-project :which-key "switch project")
    "pf" '(consult-projectile-find-file :which-key "find file in project")
    "pr" '(projectile-run-project :which-key "run")
    "pc" '(projectile-compile-project :which-key "compile")
    "pb" '(consult-projectile :which-key "consult project")

    ;; Search
    "s"  '(:ignore t :which-key "search/spell")
    "ss" '(consult-line :which-key "line")
    "sg" '(consult-ripgrep :which-key "ripgrep")
    "sd" '(my/toggle-dictionary :which-key "switch dict")
    "sc" '(flyspell-correct-wrapper :which-key "correct word")

    ;; Selection
    "v"  '(er/expand-region :which-key "expand selection")

    ;; Terminal
    "t"  '(vterm :which-key "terminal")

    ;; Help
    "h"  '(:ignore t :which-key "help")
    "hf" '(describe-function :which-key "function")
    "hv" '(describe-variable :which-key "variable")
    "hk" '(describe-key :which-key "key")

    ;; Quit
    "q"  '(:ignore t :which-key "quit")
    "qq" '(save-buffers-kill-emacs :which-key "quit")
    "q!" '((lambda () (interactive) (kill-emacs)) :which-key "quit (force)")
    "qs" '((lambda () (interactive) (save-some-buffers t) (kill-emacs)) :which-key "save & quit")

    ;; LLM (gptel)
    "a"  '(:ignore t :which-key "ai")
    "aa" '(gptel :which-key "chat")
    "as" '(gptel-send :which-key "send")
    "ar" '(gptel-rewrite :which-key "rewrite")
    "am" '(gptel-menu :which-key "menu"))

  ;; Global keybindings (work in all states)
  (general-define-key
   "M-o" 'other-window
   "M-1" 'delete-other-windows
   "M-2" 'split-window-below
   "M-3" 'split-window-right
   "M-0" 'delete-window))

;; ── File management ────────────────────────────────────────────────────────
(setq recentf-max-saved-items 50)
(recentf-mode 1)

;; Auto-revert files changed on disk
(global-auto-revert-mode 1)

;; ── Direnv Integration ──────────────────────────────────────────────────────
(use-package envrc
  :init (envrc-global-mode))

;; ── Auto-formatting ─────────────────────────────────────────────────────────
(use-package apheleia
  :init (apheleia-global-mode)
  :config
  (setf (alist-get 'nix-mode apheleia-formatters) '("nixfmt"))
  (setf (alist-get 'nix-mode apheleia-mode-alist) '(nixfmt)))

;; ── Code Snippets ───────────────────────────────────────────────────────────
(use-package yasnippet
  :init (yas-global-mode)
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets")))

(use-package yasnippet-snippets
  :after yasnippet)

;; ── Smart Selection ─────────────────────────────────────────────────────────
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; ── Better Help ─────────────────────────────────────────────────────────────
(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key)
  ([remap describe-command] . helpful-command))

;; ── Projects (Projectile) ──────────────────────────────────────────────────
(use-package projectile
  :init (projectile-mode 1)
  :config
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-switch-project-action 'projectile-dired)
  :bind-keymap ("C-c p" . projectile-command-map))

;; Integrate projectile with consult
(use-package consult-projectile
  :after (projectile consult))

;; ── Programming ────────────────────────────────────────────────────────────
;; Treesitter (Emacs 29+)
(when (treesit-available-p)
  ;; Language sources for ad-hoc compilation (fallback if not in Nix)
  (setq treesit-language-source-alist
        '((python     "https://github.com/tree-sitter/tree-sitter-python")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                      "typescript/src")
          (tsx        "https://github.com/tree-sitter/tree-sitter-typescript"
                      "tsx/src")
          (json       "https://github.com/tree-sitter/tree-sitter-json")
          (yaml       "https://github.com/tree-sitter/tree-sitter-yaml")
          (toml       "https://github.com/tree-sitter/tree-sitter-toml")
          (bash       "https://github.com/tree-sitter/tree-sitter-bash")
          (nix        "https://github.com/nix-community/tree-sitter-nix")
          (rust       "https://github.com/tree-sitter/tree-sitter-rust")
          (hyprlang   "https://github.com/tree-sitter-grammars/tree-sitter-hyprlang")))

  ;; Remap major modes to treesitter variants
  (setq major-mode-remap-alist
        '((python-mode     . python-ts-mode)
          (js-mode         . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode       . json-ts-mode)
          (yaml-mode       . yaml-ts-mode)
          (bash-mode       . bash-ts-mode)
          (rust-mode       . rust-ts-mode))))

;; Eglot (built-in LSP)
(use-package eglot
  :ensure nil
  :hook ((python-ts-mode . eglot-ensure)
         (rust-ts-mode   . eglot-ensure)
         (js-ts-mode     . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (nix-mode       . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '(nix-mode . ("nixd"))))

;; Nix mode
(use-package nix-mode
  :mode "\\.nix\\'")

;; Hyprland config mode
;; Grammar provided by NixOS (home/packages/dev.nix)
(use-package hyprlang-ts-mode
  :straight (hyprlang-ts-mode :type git :host github :repo "Nathan-Melaku/hyprlang-ts-mode")
  :mode ("hyprland\\.conf\\'" . hyprlang-ts-mode))

;; Magit
(use-package magit
  :bind ("C-x g" . magit-status))

;; ── Terminal ───────────────────────────────────────────────────────────────
(use-package vterm
  :ensure nil
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

;; ── Spell Checking (Flyspell + Spanish) ─────────────────────────────────────
(use-package flyspell-correct
  :after flyspell)

(use-package consult-flyspell
  :after consult)

(setq ispell-program-name "hunspell"
      ispell-default-dictionary "en_US")

;; Helper function to toggle Spanish/English
(defun my/toggle-dictionary ()
  "Toggle between English and Spanish dictionaries."
  (interactive)
  (if (string= ispell-local-dictionary "es_ES")
      (progn (ispell-change-dictionary "en_US")
             (message "Dictionary: English"))
    (ispell-change-dictionary "es_ES")
    (message "Dictionary: Spanish")))

;; Hooks for automatic spell checking
(add-hook 'text-mode-hook #'flyspell-mode)
(add-hook 'org-mode-hook #'flyspell-mode)
(add-hook 'prog-mode-hook #'flyspell-prog-mode) ; Comments only

;; ── Git Integration ─────────────────────────────────────────────────────────
(use-package diff-hl
  :init
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1)
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

;; ── Org Mode ─────────────────────────────────────────────────────────────────
(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package org
  :config
  (setq org-startup-indented t
        org-hide-emphasis-markers t))

;; ── Undo Visualizer ──────────────────────────────────────────────────────────
(use-package vundo
  :config
  (setq vundo-compact-display t)
  :bind ("C-x u" . vundo))

;; ── LLM Chat (gptel) ────────────────────────────────────────────────────────
(use-package gptel
  :config
  ;; API key from file (sops-nix secret)
  (setq gptel-api-key (lambda ()
                        (with-temp-buffer
                          (insert-file-contents "/run/secrets/zai_api_key")
                          (string-trim (buffer-string)))))

  ;; Z.AI provider with GLM-5 model
  (gptel-make-openai "Zai"
    :host "api.z.ai"
    :endpoint "/api/coding/paas/v4/chat/completions"
    :stream t
    :key 'gptel-api-key
    :models '((glm-5
               :description "GLM-5 reasoning model from Z.AI"
               :capabilities (reasoning tool-use)
               :context-window 128
               :input-cost 0.1
               :output-cost 0.1)))

  ;; Set Zai + GLM-5 as default
  (setq gptel-model 'glm-5
        gptel-backend (gptel-get-backend "Zai"))

  ;; ;; ── Agent Tools ───────────────────────────────────────────────────────────
  ;; ;; 1. Bash - Ejecutar comandos de shell
  ;; (gptel-make-tool
  ;;  :name "bash"
  ;;  :function (lambda (command)
  ;;              (message "Ejecutando bash: %s" command)
  ;;              (shell-command-to-string command))
  ;;  :description "Ejecuta un comando en la terminal y devuelve la salida."
  ;;  :args (list '(:name "command"
  ;;                      :type string
  ;;                      :description "Comando de shell a ejecutar")))
  ;;
  ;; ;; 2. Read - Leer archivo
  ;; (gptel-make-tool
  ;;  :name "read_file"
  ;;  :function (lambda (path)
  ;;              (if (file-exists-p path)
  ;;                  (with-temp-buffer
  ;;                    (insert-file-contents path)
  ;;                    (buffer-string))
  ;;                (format "Error: Archivo no encontrado: %s" path)))
  ;;  :description "Lee el contenido de un archivo."
  ;;  :args (list '(:name "path"
  ;;                      :type string
  ;;                      :description "Ruta completa al archivo")))
  ;;
  ;; ;; 3. Write - Escribir archivo (crear/sobrescribir)
  ;; (gptel-make-tool
  ;;  :name "write_file"
  ;;  :function (lambda (path content)
  ;;              (with-temp-file path (insert content))
  ;;              (format "Archivo escrito exitosamente: %s" path))
  ;;  :description "Escribe contenido en un archivo. Crea el archivo si no existe."
  ;;  :args (list '(:name "path"
  ;;                      :type string
  ;;                      :description "Ruta del archivo")
  ;;              '(:name "content"
  ;;                      :type string
  ;;                      :description "Contenido a escribir")))
  ;;
  ;; ;; 4. Edit - Editar archivo (reemplazo de texto)
  ;; (gptel-make-tool
  ;;  :name "edit_file"
  ;;  :function (lambda (path search replace)
  ;;              (with-current-buffer (find-file-noselect path)
  ;;                (goto-char (point-min))
  ;;                (if (search-forward search nil t)
  ;;                    (progn
  ;;                      (replace-match replace t t)
  ;;                      (save-buffer)
  ;;                      (format "Reemplazo exitoso en %s" path))
  ;;                  (format "Texto no encontrado: %s" search))))
  ;;  :description "Reemplaza una ocurrencia exacta de texto en un archivo."
  ;;  :args (list '(:name "path"
  ;;                      :type string
  ;;                      :description "Ruta del archivo")
  ;;              '(:name "search"
  ;;                      :type string
  ;;                      :description "Texto exacto a buscar")
  ;;              '(:name "replace"
  ;;                      :type string
  ;;                      :description "Texto por el cual reemplazar")))
  ;;
  ;; ;; 5. Find - Buscar archivos
  ;; (gptel-make-tool
  ;;  :name "list_files"
  ;;  :function (lambda (directory pattern)
  ;;              (mapconcat #'identity
  ;;                         (directory-files-recursively directory pattern)
  ;;                         "\n"))
  ;;  :description "Lista archivos en un directorio que coincidan con un patrón."
  ;;  :args (list '(:name "directory"
  ;;                      :type string
  ;;                      :description "Directorio donde buscar")
  ;;              '(:name "pattern"
  ;;                      :type string
  ;;                      :description "Patrón regex (ej: \\.el$)")))
  ;;
  ;; ;; 6. Grep - Buscar dentro de archivos
  ;; (gptel-make-tool
  ;;  :name "grep_search"
  ;;  :function (lambda (pattern path)
  ;;              (shell-command-to-string
  ;;               (format "grep -rn '%s' '%s' 2>/dev/null || echo 'Sin resultados'"
  ;;                       pattern path)))
  ;;  :description "Busca texto dentro de archivos recursivamente."
  ;;  :args (list '(:name "pattern"
  ;;                      :type string
  ;;                      :description "Texto a buscar")
  ;;              '(:name "path"
  ;;                      :type string
  ;;                      :description "Directorio o archivo base")))
  ;;
  ;; (setq gptel-tools (gptel-get-tool '("bash" "read_file" "write_file")))

  ;; ── End Agent Tools

  ;; Keybindings
  :bind (("C-c RET" . gptel-send)
         ("C-c g"   . gptel)
         ("C-c M-g" . gptel-rewrite)))

;; gptel-agent mode
;; Patch: fix SKILL.md regex to not match .backup files
(use-package gptel-agent
  :straight (gptel-agent :type git :host github :repo "karthink/gptel-agent"
                         :pre-build ((lambda ()
                                       (shell-command
                                        (format "patch -p1 < %s"
                                                (shell-quote-argument
                                                 (expand-file-name "patches/gptel-agent-skill-md-anchor.patch"
                                                                   user-emacs-directory)))))))
  :config (gptel-agent-update))         ;Read files from agents directories

;; ── SOPS Auto Encryption/Decryption ─────────────────────────────────────────
;; Automatically decrypt SOPS-encrypted files on open and encrypt on save
(defvar-local sops--encrypted nil
  "Non-nil if current buffer contains decrypted SOPS content.")

(defun sops--is-encrypted-p ()
  "Check if current buffer contains SOPS-encrypted content."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward "ENC\\[" (+ (point-min) 1000) t)))

(defun sops--decrypt-buffer ()
  "Decrypt current buffer using sops."
  (let* ((file (buffer-file-name))
         (temp-file (make-temp-file "sops-decrypt" nil ".yaml"))
         (status 0))
    (when (and file (sops--is-encrypted-p))
      ;; Decrypt to temp file
      (setq status (call-process "sops" nil `(:file ,temp-file) nil "--decrypt" file))
      (if (and (numberp status) (= status 0))
          (progn
            ;; Replace buffer content with decrypted content
            (erase-buffer)
            (insert-file-contents temp-file)
            (setq sops--encrypted t)
            (set-buffer-modified-p nil)
            (message "SOPS: Decrypted %s" (file-name-nondirectory file)))
        (message "SOPS: Decryption failed (exit code %s)" status))
      (when (file-exists-p temp-file)
        (delete-file temp-file)))))

(defun sops--find-config ()
  "Find .sops.yaml by walking up from current file's directory."
  (let ((dir (file-name-directory (buffer-file-name))))
    (while (and dir
                (not (string= dir "/"))
                (not (file-exists-p (expand-file-name ".sops.yaml" dir))))
      (setq dir (file-name-directory (directory-file-name dir))))
    (when (file-exists-p (expand-file-name ".sops.yaml" dir))
      (expand-file-name ".sops.yaml" dir))))

(defun sops--encrypt-buffer ()
  "Encrypt current buffer using sops, writing encrypted content to file."
  (when sops--encrypted
    (let* ((file (buffer-file-name))
           (filename (file-name-nondirectory file))
           (config (sops--find-config))
           (temp-decrypted (make-temp-file "sops-decrypted" nil ".yaml"))
           (temp-encrypted (make-temp-file "sops-encrypted" nil ".yaml"))
           (status 0)
           (args '()))
      (unless config
        (error "SOPS: No .sops.yaml found"))
      ;; Write current (decrypted) content to temp file
      (write-region (point-min) (point-max) temp-decrypted nil 'silent)
      ;; Build args: --config, --filename-override for path_regex match, --encrypt
      (setq args (list "--config" config
                       "--filename-override" filename
                       "--encrypt" temp-decrypted))
      (setq status (apply #'call-process "sops" nil `(:file ,temp-encrypted) nil args))
      (if (and (numberp status) (= status 0))
          ;; Write encrypted content to actual file
          (let ((encrypted-content (with-temp-buffer
                                     (insert-file-contents temp-encrypted)
                                     (buffer-string))))
            (write-region encrypted-content nil file nil 'silent)
            (message "SOPS: Encrypted and saved"))
        (message "SOPS: Encryption failed (exit code %s)" status))
      (delete-file temp-decrypted)
      (when (file-exists-p temp-encrypted)
        (delete-file temp-encrypted)))))

(defun sops--save-file ()
  "Encrypt and save current buffer. Returns t to prevent default save."
  (when sops--encrypted
    (sops--encrypt-buffer)
    ;; Mark buffer as unmodified since we already saved
    (set-buffer-modified-p nil)
    t))  ; Return t to signal we handled the save

(defun sops--setup-hooks ()
  "Setup SOPS hooks for current buffer if it matches secrets pattern."
  (let ((file (buffer-file-name)))
    (when (and file
               (string-match-p "\\(secrets?\\.ya?ml\\|.secret\\.ya?ml\\|/secrets?/.+\\.ya?ml\\)" file))
      ;; Decrypt on open
      (sops--decrypt-buffer)
      ;; Use write-contents-functions - returning t prevents default save
      (add-hook 'write-contents-functions #'sops--save-file nil t))))

(add-hook 'find-file-hook #'sops--setup-hooks)

;; Manual commands
(defun sops-encrypt-buffer ()
  "Manually mark current buffer for SOPS encryption on save."
  (interactive)
  (setq sops--encrypted t)
  (message "Marked for SOPS encryption on save"))

(defun sops-decrypt-buffer ()
  "Manually decrypt current SOPS file."
  (interactive)
  (sops--decrypt-buffer))

(defun sops-status ()
  "Show SOPS status for current buffer."
  (interactive)
  (message "SOPS: %s"
           (cond (sops--encrypted "Encrypted (will encrypt on save)")
                 ((sops--is-encrypted-p) "Encrypted file (not decrypted)")
                 (t "Not managed"))))

(provide 'init)
;; ============================================================================
;; End of init.el
;; ============================================================================
