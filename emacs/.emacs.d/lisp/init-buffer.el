;;; init-buffer.el --- Config for minibuffer completion       -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:


(use-package vertico)
(vertico-mode t)


(use-package orderless)
(setq completion-styles '(orderless))


(use-package marginalia)
(marginalia-mode t)


(use-package embark
  :bind
  ("M-h b" . embark-bindings)
  :custom
  (embark-help-key "?"))


(use-package consult)
(global-set-key [remap goto-line] 'consult-goto-line)
(global-set-key [remap isearch-forward] 'consult-line)
(global-set-key [remap switch-to-buffer] 'consult-buffer)
(global-set-key [remap project-find-regexp] 'consult-ripgrep)
(global-set-key [remap project-switch-to-buffer] 'consult-project-buffer)



(provide 'init-buffer)
;;; init-buffer.el ends here
