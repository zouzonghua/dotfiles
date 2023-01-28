;;; init-eglot.el --- Configure keys specific to MacOS -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; Languages Server Protocol(LSP)

(use-package eglot
  :hook ((
          js-mode
          typescript-mode
          web-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c e a" . eglot-code-actions)
              ("C-c e r" . eglot-rename)
              ("C-c e f" . eglot-format)
              ("C-c e d" . eldoc))
  :config
  (setq read-process-output-max (* 1024 1024))
  (setq completion-category-defaults nil))

(provide 'init-eglot)
;;; init-eglot.el ends here
