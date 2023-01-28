;;; init-ui.el --- Behaviour specific to non-TTY frames -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq-default initial-scratch-message
  (concat ";; Happy hacking, " user-login-name " - Emacs ♥ you!\n\n"))


;; Set default theme
(setq   modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-region '(bg-only no-extend))
(load-theme 'modus-vivendi)


;; Set default font
(set-face-attribute 'default nil
                    :family "MesloLGM Nerd Font"
                    :height 140
                    :weight 'normal
                    :width 'normal)


;; Suppress GUI features
(setq use-file-dialog nil)
(setq use-dialog-box nil)
(setq inhibit-startup-screen t)


;; Window features
(setq-default
 window-resize-pixelwise t
 frame-resize-pixelwise t)

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))

(menu-bar-mode -1)

(when *is-a-mac*
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(when *is-a-mac*
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))

(setq frame-title-format
      '((:eval (if (buffer-file-name)
                   (abbreviate-file-name (buffer-file-name))
                 "%b"))))

;; Non-zero values for `line-spacing' can mess up ansi-term and co,
;; so we zero it explicitly in those cases.
(add-hook 'term-mode-hook
          (lambda ()
            (setq line-spacing 0)))


(provide 'init-ui)
;;; init-ui.el ends here
