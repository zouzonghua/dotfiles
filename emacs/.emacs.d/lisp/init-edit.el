;;; init-edit.el --- Day-to-day editing helpers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (fboundp 'electric-pair-mode)
  (add-hook 'after-init-hook 'electric-pair-mode))
(add-hook 'after-init-hook 'electric-indent-mode)


;;; Some basic preferences
(setq-default
 blink-cursor-interval 0.4
 bookmark-default-file (locate-user-emacs-file ".bookmarks.el")
 buffers-menu-max-size 30
 case-fold-search t
 column-number-mode t
 ediff-split-window-function 'split-window-horizontally
 ediff-window-setup-function 'ediff-setup-windows-plain
 indent-tabs-mode nil
 create-lockfiles nil
 auto-save-default nil
 make-backup-files nil
 mouse-yank-at-point t
 save-interprogram-paste-before-kill t
 scroll-preserve-screen-position 'always
 scroll-error-top-bottom t
 )
(global-hl-line-mode t)

(add-hook 'after-init-hook 'delete-selection-mode)
(add-hook 'after-init-hook 'global-auto-revert-mode)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)
(with-eval-after-load 'autorevert
  (diminish 'auto-revert-mode))
(add-hook 'after-init-hook 'transient-mark-mode)

(fset 'yes-or-no-p 'y-or-n-p)


;;; Whitespace
(setq-default show-trailing-whitespace nil)

(defun show-trailing-whitespace ()
  "Enable display of trailing whitespace in this buffer."
  (setq-local show-trailing-whitespace t))

(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook 'show-trailing-whitespace))


;;; Display line numbers
(when (fboundp 'display-line-numbers-mode)
  (setq-default display-line-numbers-width 3)
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (add-hook 'text-mode-hook 'display-line-numbers-mode))


;;; Display fill column indicator
(when (fboundp 'display-fill-column-indicator-mode)
;;  (setq-default indicate-buffer-boundaries 'left)
  (setq-default display-fill-column-indicator-column 80)
  (setq-default display-fill-column-indicator-character ?\u254e)
  (add-hook 'text-mode-hook 'display-fill-column-indicator-mode)
  (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))


;;; Hideshow
 (add-hook 'prog-mode-hook 'hs-minor-mode)
 (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
 (global-set-key (kbd "C-M-[") 'hs-show-block)
 (global-set-key (kbd "C-M-]") 'hs-hide-block)


;;; Newline behaviour
;;; TTY not support
(defun newline-at-end-of-line ()
  "Move to end of line, enter a newline, and reindent."
  (interactive)
  (move-end-of-line 1)
  (newline-and-indent))

(defun newline-at-previous-of-line ()
  "Move to previous of line, enter a newline, and reindent."
  (interactive)
  (move-beginning-of-line 1)
  (previous-line 1)
  (newline-and-indent))

(when *is-a-gui*
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-<return>") 'newline-at-end-of-line)
(global-set-key (kbd "C-S-<return>") 'newline-at-previous-of-line))


;;; Copy & paste
;;; @see https://stackoverflow.com/questions/64360/how-to-copy-text-from-emacs-to-another-application-on-linux/19625063#19625063
;;; @sww http://blog.lujun9972.win/emacs-document/blog/2018/05/31/zsh,-tmux,-emacs-%E4%BB%A5%E5%8F%8A-ssh-%E4%B8%80%E4%B8%AA%E5%85%B3%E4%BA%8E%E7%B2%98%E5%B8%96%E5%A4%8D%E5%88%B6%E7%9A%84%E6%95%85%E4%BA%8B/index.html
;;; GUI not support
(defun copy-from-terminal (text)
 "Store text in the clipboard from a terminal Emacs."
 (if window-system
     (error "Trying to copy text in GUI emacs.")
   (with-temp-buffer
     (insert text)
     (call-process-region (point-min) (point-max) "pbcopy"))))

(defun buffer-substring-terminal-filter (beg end &optional delete)
 "A filter that uses the default filter but also adds text to clipboard."
 (let ((result (buffer-substring--filter beg end delete)))
   ;; Only copy sizable entries to avoid unnecessary system calls.
   (when (> (length result) 4)
     (copy-from-terminal result))
   result))

(when *is-a-tty*
 (setq-default filter-buffer-substring-function #'buffer-substring-terminal-filter))


;;; TTY copy&paste
; (use-package clipetty
;   :hook (after-init . global-clipetty-mode))
; (setq clipetty-tmux-ssh-tty "tmux show-environment SSH_TTY_XXXXX")


(use-package valign)
(add-hook 'org-mode-hook #'valign-mode)
(add-hook 'markdown-mode-hook #'valign-mode)


;; Huge files
(when (fboundp 'so-long-enable)
  (add-hook 'after-init-hook 'so-long-enable))
(use-package vlf)
(defun ffap-vlf ()
  "Find file at point with VLF."
  (interactive)
  (let ((file (ffap-file-at-point)))
    (unless (file-exists-p file)
      (error "File does not exist: %s" file))
    (vlf file)))


;;; Mode line bell
(use-package mode-line-bell
  :init
  (add-hook 'after-init-hook 'mode-line-bell-mode))


;;; Beacon
;(use-package beacon
;  :config
;  (setq-default beacon-lighter "")
;  (setq-default beacon-size 20)
;  :init
;  (add-hook 'after-init-hook 'beacon-mode))


;;; Rainbow delimiters
(use-package rainbow-delimiters
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))



(provide 'init-edit)
;;; init-edit.el ends here
