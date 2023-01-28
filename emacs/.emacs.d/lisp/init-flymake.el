;;; init-flymake.el --- Configure keys specific to MacOS -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package flymake
  :hook (prog-mode . flymake-mode)
  :config
  (global-set-key (kbd "M-n") #'flymake-goto-next-error)
  (global-set-key (kbd "M-p") #'flymake-goto-prev-error))

(use-package flymake-eslint
  :config
  (add-hook 'typescript-mode-hook (lambda () (flymake-eslint-enable)))
  (add-hook 'js-mode-hook (lambda () (flymake-eslint-enable))))

(provide 'init-flymake)
;;; init-flymake.el ends here
