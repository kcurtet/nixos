;; -*- lexical-binding: t; -*-
;; ============================================================================
;; Init.el — Minimal Emacs Configuration (Nord Theme)
;; ============================================================================

;; ── Package management ─────────────────────────────────────────────────────
(require 'package)
(setq package-archives
      '(("melpa"  . "https://melpa.org/packages/")
        ("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

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

;; Frame transparency (75% opacity)
(set-frame-parameter nil 'alpha-background 75)
(add-to-list 'default-frame-alist '(alpha-background . 75))

;; Disable line numbers in some modes
(dolist (mode '(term-mode-hook
               shell-mode-hook
               eshell-mode-hook
               vterm-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Font
(set-face-attribute 'default nil
                    :family "JetBrainsMono Nerd Font"
                    :height 140)

;; ── Theme (Nord) ───────────────────────────────────────────────────────────
(use-package nord-theme
  :config
  (load-theme 'nord t))

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
         ("M-s r" . consult-ripgrep)))

;; ── Which Key ──────────────────────────────────────────────────────────────
(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.5))

;; ── File management ────────────────────────────────────────────────────────
(setq recentf-max-saved-items 50)
(recentf-mode 1)

;; Auto-revert files changed on disk
(global-auto-revert-mode 1)

;; ── Programming ────────────────────────────────────────────────────────────
;; Treesitter (Emacs 29+)
(when (treesit-available-p)
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
          (rust       "https://github.com/tree-sitter/tree-sitter-rust")))

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

;; Magit
(use-package magit
  :bind ("C-x g" . magit-status))

;; ── Terminal ───────────────────────────────────────────────────────────────
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

;; ── Keybindings ────────────────────────────────────────────────────────────
;; Unbind annoying defaults
(global-unset-key (kbd "C-z"))  ; suspend-frame

;; Window management
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-1") 'delete-other-windows)
(global-set-key (kbd "M-2") 'split-window-below)
(global-set-key (kbd "M-3") 'split-window-right)
(global-set-key (kbd "M-0") 'delete-window)

(provide 'init)
;; ============================================================================
;; End of init.el
;; ============================================================================
