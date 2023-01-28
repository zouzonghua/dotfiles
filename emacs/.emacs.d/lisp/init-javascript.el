;;; init-javascript.el --- Configure keys specific to MacOS -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package typescript-mode
  :mode (("\\.ts\\'" . typescript-mode)
	 ("\\.tsx\\'" . typescript-tsx-mode))
  :config
  (define-derived-mode typescript-tsx-mode typescript-mode "tsx")
  (with-eval-after-load 'tree-sitter-langs
    ;; https://github.com/emacs-typescript/typescript.el/issues/4#issuecomment-873485004
    (add-to-list 'tree-sitter-major-mode-language-alist '(typescript-tsx-mode . tsx))))

(provide 'init-javascript)
;;; init-javascript.el ends here
