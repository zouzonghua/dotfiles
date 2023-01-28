;;; init-company.el --- Configure keys specific to MacOS -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package company
  :hook (after-init . global-company-mode)
  :config 
  (define-key company-active-map (kbd "C-h") 'delete-backward-char)
  (setq company-minimum-prefix-length 1
                company-show-quick-access t))

(provide 'init-company)
;;; init-company.el ends here
