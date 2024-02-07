(setq package-archives '(("gnu"    . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                          ("melpa"  . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(add-to-list 'load-path (concat user-emacs-directory "lisp"))
(unless (bound-and-true-p my-computer-has-smaller-memory-p)
  (setq gc-cons-percentage 0.6)
  (setq gc-cons-threshold most-positive-fixnum))
(defun my-initialize-package ()
  (when (or (featurep 'esup-child)
            (fboundp 'profile-dotemacs)
            (daemonp)
          noninteractive)
    (setq package-enable-at-startup nil)
    (package-initialize)))
(my-initialize-package)
(setq-default

  warning-suppress-log-types '((comp))

  ;; Backup setups
  ;; We use temporary directory /tmp for backup files
  ;; More versions should be saved
  backup-directory-alist `((".*" . ,temporary-file-directory))
  auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
  backup-by-copying t
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t

  ;; Don't wait for keystrokes display
  echo-keystrokes 0.01

  ;; Disable margin for overline and underline
  overline-margin 0
  underline-minimum-offset 0

  ;; Better scroll behavior
  mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil))
  mouse-wheel-progressive-speed nil

  ;; Disable copy region blink
  copy-region-blink-delay 0

  ;; Use short answer when asking yes or no
  read-answer-short t

  ;; Mouse yank at current point
  mouse-yank-at-point t

  ;; DWIM target for dired
  ;; Automatically use another dired buffer as target for copy/rename
  dired-dwim-target t

  )
(scroll-bar-mode 0)
(setq create-lockfiles nil)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(set-window-scroll-bars (minibuffer-window) nil nil)
(setq-default cursor-in-non-selected-windows nil)
(setq word-wrap-by-category t)
(toggle-word-wrap)
;; (setq-default truncate-lines t)
(setq byte-compile-warnings nil)
(setq shr-max-image-proportion 0.7)
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default default-directory "~/")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))
(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))
(add-hook 'prog-mode-hook 'electric-pair-local-mode)
(add-hook 'conf-mode-hook 'electric-pair-local-mode)
(use-package saveplace
  :ensure nil
  :hook
  (text-mode . save-place-mode))
(use-package imenu
  :bind
  ("C-'" . imenu))
(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode))
(use-package recentf
  :ensure nil
  :defer 0.1
  :bind
  ("C-c o" . recentf-open)
  :init
  (setq recentf-max-saved-items 1000)
  (setq recentf-exclude '("/tmp/" "/ssh:"))
  (recentf-mode 1))
(setq pixel-scroll-precision-interpolate-page t) ;; smooth scroll M-v C-v
(pixel-scroll-precision-mode)
(defun +pixel-scroll-interpolate-down (&optional lines)
  (interactive)
  (if lines
      (pixel-scroll-precision-interpolate (* -1 lines (pixel-line-height)))
    (pixel-scroll-interpolate-down)))

(defun +pixel-scroll-interpolate-up (&optional lines)
  (interactive)
  (if lines
      (pixel-scroll-precision-interpolate (* lines (pixel-line-height))))
  (pixel-scroll-interpolate-up))

(defalias 'scroll-up-command '+pixel-scroll-interpolate-down)
(defalias 'scroll-down-command '+pixel-scroll-interpolate-up)
(require 'init-lib)
(require 'init-fonts)
(use-package corfu
  :ensure t
  :hook ((prog-mode . corfu-mode)
          (shell-mode . corfu-mode)
          (eshell-mode . corfu-mode))
  :bind
  (:map corfu-map
    ("SPC" . corfu-insert-separator)
    ("C-<return>" . newline))

  :config
  (setq corfu-auto t)
  (setq corfu-quit-no-match t)
  (setq corfu-auto-prefix 1)
  (setq corfu-auto-delay 0.1)
  (setq completion-styles '(orderless basic)))


;;; customize
(load-theme 'modus-operandi t)

(use-package gptel
  :ensure t)

(use-package nov
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  :config
  (add-hook 'nov-mode-hook (lambda () (setq truncate-lines t))))

(use-package immersive-translate
  :ensure t
  :init
  (add-hook 'elfeed-show-mode-hook #'immersive-translate-setup)
  (add-hook 'nov-pre-html-render-hook #'immersive-translate-setup)
  :hook
  (nov-mode . immersive-translate-auto-mode)
  :config
  (setq immersive-translate-backend 'baidu
	immersive-translate-baidu-appid "20231121001887650")
  (setq immersive-translate-exclude-shr-tag (remove 'div immersive-translate-exclude-shr-tag)))

(defun my-cleanup-gc ()
  "Clean up gc."
  (setq gc-cons-threshold  67108864) ; 64M
  (setq gc-cons-percentage 0.1) ; original value
  (garbage-collect))

(run-with-idle-timer 4 nil #'my-cleanup-gc)

;; startup done
(run-with-timer 0.2 nil
  (lambda ()
    (message "*** Emacs loaded in %s with %d garbage collections."
      (format "%.2f seconds"
        (float-time (time-subtract after-init-time before-init-time)))
      gcs-done)))
