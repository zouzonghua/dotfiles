;;; init-flycheck.el --- Configure keys specific to MacOS -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package flycheck
  :custom
  (flycheck-navigation-minimum-level 'warning)
  :config
  (global-set-key (kbd "M-n") #'flycheck-next-error)
  (global-set-key (kbd "M-p") #'flycheck-previous-error))


(provide 'init-flycheck)
;;; init-flycheck.el ends here
