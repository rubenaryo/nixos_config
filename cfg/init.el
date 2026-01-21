;;; init.el --- Minimal Emacs config with Straight.el, use-package, doom-themes, and doom-dashboard

;; -----------------------------
;; Bootstrap straight.el
;; -----------------------------
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Make use-package use straight by default
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; -----------------------------
;; Nix Mode
;; -----------------------------
(use-package nix-mode
  :mode "\\.nix\\'")

;; -----------------------------
;; Eglot
;; -----------------------------
(use-package eglot
  :straight t
  :hook ((c-mode c++-mode) . eglot-ensure))

;; -----------------------------
;; Eglot Inactive Regions
;; -----------------------------
(use-package eglot-inactive-regions
  :custom
  (eglot-inactive-regions-style 'darken-foreground)
  (eglot-inactive-regions-opacity 0.4)
  :config
  (eglot-inactive-regions-mode 1))

(use-package clang-format
  :ensure t  ;; installs from MELPA if not present
  :init

  :config
  ;; Keybinding to format current buffer
  (global-set-key (kbd "C-c C-f") 'clang-format-buffer)

  ;; Optional: automatically format C/C++ buffers on save
  (defun my/clang-format-on-save ()
    (add-hook 'before-save-hook 'clang-format-buffer nil t))

  (add-hook 'c-mode-common-hook 'my/clang-format-on-save))

;; -----------------------------
;; VTerm
;; -----------------------------
(use-package vterm
  :straight t
  :defer t  ; Defer loading until explicitly called
  :commands (vterm switch-to-vterm-buffer) ; Define commands to trigger loading
  :config
  ;; Optional: Add keybindings or extra configurations here
  (global-set-key (kbd "C-c t") 'vterm)
  ;; Optional: Better scrolling (adjust as needed)
  (setq vterm-max-scrollback 10000)
  )

;; -----------------------------
;; Tramp - Clean and Simple
;; -----------------------------
(use-package tramp
  :config
  ;; This is the ONLY way to stop the hex garble in modern TRAMP
  (setq tramp-connection-local-default-shell-variables
        '((tramp-direct-async-process . t)
          (tramp-remote-shell . "/bin/sh")
          (tramp-remote-shell-args . ("-c")))))

;; -----------------------------
;; Eglot + TRAMP Optimization
;; -----------------------------
;; This ensures Eglot uses the same "Direct Async" logic we want for GDB
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode) . ("clangd"))))

;; -----------------------------
;; Fix for the "Scan Error"
;; -----------------------------
;; Force TRAMP to be "quiet" so it doesn't leak prompts into the data stream
(setq tramp-copy-size-limit nil)
(setq tramp-inline-compress-start nil)

;; -----------------------------
;; Doom Themes
;; -----------------------------
(use-package doom-themes
  :straight t
  :config
  ;; Load your preferred Doom theme
  (load-theme 'doom-one t))

;; -----------------------------
;; Nerd Icons
;; -----------------------------
(use-package nerd-icons
  :straight t)

;; -----------------------------
;; Dashboard (base package)
;; -----------------------------
(use-package dashboard
  :straight t
  :config
  ;; Setup the dashboard hooks
  (dashboard-setup-startup-hook)
  ;; Optional: configure basic dashboard items
  (setq dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (bookmarks . 5)
                          (agenda    . 5))))

;; -----------------------------
;; Doom Dashboard (disabled)
;; -----------------------------
(when nil
(use-package doom-dashboard
  ;; For Straight Users
  :straight (doom-dashboard :host github
                                :repo "emacs-dashboard/doom-dashboard")
  ;; OR for built-in package-vc
  ;; :vc (:url "https://github.com/emacs-dashboard/doom-dashboard.git" :rev :newest)
  :after dashboard
  :demand t
  ;; Movement keys like doom.
  :bind
  (:map dashboard-mode-map
        ("<remap> <dashboard-previous-line>" . widget-backward)
        ("<remap> <dashboard-next-line>" . widget-forward)
        ("<remap> <previous-line>" . widget-backward)
        ("<remap> <next-line>"  . widget-forward)
        ("<remap> <right-char>" . widget-forward)
        ("<remap> <left-char>"  . widget-backward))
  :custom
  (dashboard-banner-logo-title "E M A C S")
  (dashboard-startup-banner  
    (expand-file-name "doom-dashboard/bcc.txt" user-emacs-directory))
  (dashboard-footer-icon 
    (nerd-icons-faicon "nf-fa-github_alt" :face 'success :height 1.5))
  (dashboard-page-separator "\n")
  (dashboard-startupify-list `(dashboard-insert-banner
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-items
                               ,(dashboard-insert-newline 2)
                               dashboard-insert-init-info
                               ,(dashboard-insert-newline 2)
                               doom-dashboard-insert-homepage-footer))
  (dashboard-item-generators
   '((recents   . doom-dashboard-insert-recents-shortmenu)
     (bookmarks . doom-dashboard-insert-bookmark-shortmenu)
     (projects  . doom-dashboard-insert-project-shortmenu)
     (agenda    . doom-dashboard-insert-org-agenda-shortmenu)))
  (dashboard-items '(projects agenda bookmarks recents)))
)

;; -----------------------------
;; Recent files
;; -----------------------------
(use-package recentf
  :config
  (setq recentf-max-saved-items 200)
  (recentf-mode 1))

;; -----------------------------
;; Projects
;; -----------------------------
(use-package project
  :config
  ;; Optional: specify file to persist projects
  (setq project-list-file (expand-file-name "projects" user-emacs-directory)))

;; -----------------------------
;; Leetcode
;; -----------------------------
(use-package leetcode
  :ensure t
  :custom
  (leetcode-prefer-language "cpp")    ; Options: "cpp", "java", "python3", "javascript", etc.
  (leetcode-save-solutions t)             ; Automatically save your code
  (leetcode-directory "~/.leetcode")       ; Directory to store your local solutions
  :config
  ;; Optional: Disable flycheck in solution buffers if it's too noisy
  (add-hook 'leetcode-solution-mode-hook (lambda () (flycheck-mode -1))))

;; -----------------------------
;; Optional / basic settings
;; -----------------------------
;; Show line numbers
(global-display-line-numbers-mode t)

;; Smooth scrolling
(pixel-scroll-mode 1)

;; Suppress startup message
(setq inhibit-startup-message t)

;; Always open dashboard on startup
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

;; Delete selection when new things are typed
(delete-selection-mode 1)

;; Set font and size
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-14"))

;; Set ipv4 preference
(setq network-lookup-address-preference 'ipv4)

;; -----------------------------
;; Temporary / Backup directory
;; -----------------------------
(defvar my/tmp-dir (expand-file-name "tmp/" user-emacs-directory)
  "Directory to store all temporary files.")

;; Create the directory if it doesn't exist
(unless (file-exists-p my/tmp-dir)
  (make-directory my/tmp-dir t))

;; Move backup files there
(setq backup-directory-alist `(("." . ,my/tmp-dir))
      backup-by-copying t    ;; don't clobber symlinks
      version-control t      ;; use numbered backups
      delete-old-versions t  ;; delete old backups silently
      kept-new-versions 6
      kept-old-versions 2)

;; Move auto-save files there
(setq auto-save-file-name-transforms `((".*" ,my/tmp-dir t)))

;; -----------------------------
;; Go to header/source
;; -----------------------------
(defun my/find-corresponding-header ()
  "Find the corresponding header/source file for the current buffer."
  (interactive)
  (let* ((ext (file-name-extension buffer-file-name))
         (base (file-name-sans-extension buffer-file-name))
         (candidates
          (cond
           ((member ext '("c" "cpp" "cc")) (list (concat base ".h") (concat base ".hpp")))
           ((member ext '("h" "hpp")) (list (concat base ".c") (concat base ".cpp") (concat base ".cc")))
           (t nil))))
    (if candidates
        (let ((found (seq-find #'file-exists-p candidates)))
          (if found
              (find-file found)
            (message "No corresponding file found")))
      (message "Buffer is not a recognized source/header file"))))

(setq gdb-many-windows t)
;; User keybinds and settings

;; C/C++

;; Global keybinds
(global-set-key (kbd "C-c o") #'my/find-corresponding-header)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "M-l") 'isearch-forward)
(define-key isearch-mode-map (kbd "M-l") 'isearch-repeat-forward)
(global-set-key (kbd "M-k") 'isearch-backward)
(define-key isearch-mode-map (kbd "M-k") 'isearch-repeat-backward)

(defun move-line-up ()
  "Move current line up by one."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move current line down by one."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-<up>") 'move-line-up)

(provide 'init)
;;; init.el ends here
