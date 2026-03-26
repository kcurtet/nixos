;; -*- lexical-binding: t; -*-
;; ============================================================================
;; Early Init — runs before package system and UI
;; ============================================================================

;; Reduce GC during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Restore after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)  ; 16MB
                  gc-cons-percentage 0.1)))

;; Disable package.el (we use use-package + straight or built-in)
(setq package-enable-at-startup nil)

;; Prevent UI flash
(setq inhibit-redisplay t
      inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq inhibit-redisplay nil
                  inhibit-message nil)
            (redisplay)))

;; Disable UI chrome early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)


;; Native compilation settings
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t))
