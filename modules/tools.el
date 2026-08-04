;; Disable auto-polling and auto-redraw so magit-style folds don't get blown away.
;; Use manual refresh (e.g. `gr` / `revert-buffer`) when you actually want it.
(setq kubernetes-poll-frequency nil
      kubernetes-redraw-frequency nil)

(map! :leader
      :prefix ("o" . "open")
      :desc "Kubernetes (overview)" "k" #'kubernetes-overview)

(after! kubernetes
  ;; Start kubernetes.el buffers in Evil normal state.
  (evil-set-initial-state 'kubernetes-overview-mode 'normal)
  (evil-set-initial-state 'kubernetes-display-thing-mode 'normal)
  (evil-set-initial-state 'kubernetes-log-line-mode 'normal)
  (evil-set-initial-state 'kubernetes-logs-mode 'normal)

  ;; Display kubernetes.el buffers in a side window (like Magit) instead of
  ;; taking over the whole frame.
  (setq display-buffer-alist
        (append display-buffer-alist
                '(("\\*kubernetes"
                   (display-buffer-reuse-window display-buffer-in-side-window)
                   (side . right)
                   (slot . 0)
                   (window-width . 0.4)
                   (reusable-frames . visible))))))

;; Evil bindings for kubernetes-overview-mode (the main UI).
;; Defined separately so the keymap exists when bindings are applied.
(after! kubernetes-overview
  (map! :map kubernetes-overview-mode-map
        ;; Navigation
        :n "j"   #'magit-section-forward
        :n "k"   #'magit-section-backward
        :n "gj"  #'magit-section-forward-sibling
        :n "gk"  #'magit-section-backward-sibling
        :n "gg"  #'beginning-of-buffer
        :n "G"   #'end-of-buffer
        :n "^"   #'magit-section-up
        :n [tab] #'magit-section-toggle
        :n [return] #'kubernetes-navigate

        ;; Folding
        :n "za"  #'magit-section-toggle
        :n "zo"  #'magit-section-show
        :n "zc"  #'magit-section-hide
        :n "zO"  #'magit-section-show-children
        :n "zC"  #'magit-section-hide-children

        ;; Actions
        :n "gr"  #'kubernetes-refresh
        :n "q"   #'quit-window
        :n "Q"   #'kubernetes-kill-buffers-and-processes
        :n "d"   #'kubernetes-describe
        :n "l"   #'kubernetes-logs
        :n "e"   #'kubernetes-exec
        :n "f"   #'kubernetes-file
        :n "E"   #'kubernetes-edit
        :n "y"   #'kubernetes-copy-thing-at-point

        ;; Marking/deletion
        :n "D"   #'kubernetes-mark-for-delete
        :n "u"   #'kubernetes-unmark
        :n "U"   #'kubernetes-unmark-all
        :n "x"   #'kubernetes-execute-marks

        ;; Context/config
        :n "C"   #'kubernetes-context
        :n "L"   #'kubernetes-labels
        :n "T"   #'kubernetes-events
        :n "v"   #'kubernetes-overview-set-sections
        :n "?"   #'kubernetes-dispatch
        :n "c"   #'kubernetes-config-popup
        :n "P"   #'kubernetes-proxy))

;; (use-package! kele
;;   :init
;;   (map! :leader
;;         :desc "Kubernetes (kele)" "k" #'kele-dispatch))
;;
;; (after! kele
;;   (evil-set-initial-state 'kele-list-mode 'normal)
;;   (evil-set-initial-state 'kele-get-mode 'normal)
;;
;;   ;; List mode (viewing pods, deployments, etc.)
;;   (map! :map kele-list-mode-map
;;         :n "j" #'evil-next-line
;;         :n "k" #'evil-previous-line
;;         :n "gg" #'beginning-of-buffer
;;         :n "G" #'end-of-buffer
;;         :n "q" #'quit-window
;;         :n "gr" #'kele-list-refresh
;;         :n [return] #'kele-list-table-dwim
;;         :n "d" #'kele-list-kill
;;         :n [tab] #'vtable-next-column
;;         :n [backtab] #'vtable-previous-column
;;         :n "]]" #'magit-section-forward
;;         :n "[[" #'magit-section-backward
;;         :n "gj" #'magit-section-forward-sibling
;;         :n "gk" #'magit-section-backward-sibling
;;         :n "za" #'magit-section-toggle
;;         :n "zc" #'magit-section-hide
;;         :n "zo" #'magit-section-show)
;;
;;   ;; Get mode (viewing resource YAML)
;;   (map! :map kele-get-mode-map
;;         :n "j" #'evil-next-line
;;         :n "k" #'evil-previous-line
;;         :n "gg" #'beginning-of-buffer
;;         :n "G" #'end-of-buffer
;;         :n "q" #'quit-window
;;         :n "Q" #'kele--quit-and-kill
;;         :n "gr" #'kele-refetch)
;;
;;   ;; Table navigation
;;   (map! :map kele-list-table-map
;;         :n [return] #'kele-list-table-dwim
;;         :n "d" #'kele-list-kill))

(defun my/wsl-p ()
  "Return non-nil when Emacs is running inside Windows Subsystem for Linux."
  (and (eq system-type 'gnu/linux)
       (or (getenv "WSL_DISTRO_NAME")
           (let ((proc-version "/proc/version"))
             (and (file-readable-p proc-version)
                  (with-temp-buffer
                    (insert-file-contents proc-version)
                    (string-match-p "microsoft"
                                    (downcase (buffer-string)))))))))

(defvar my/gptel-codex-model
  (or (getenv "GPTEL_CODEX_MODEL") 'gpt-5.2)
  "Codex model used by gptel when running on WSL.")

(defvar my/eca-codex-model
  (or (getenv "ECA_CODEX_MODEL") "openai/gpt-5-codex")
  "Codex model used by eca-emacs when running on WSL.")

(after! gptel
  (let ((use-codex (my/wsl-p)))
    (setq gptel-model (if use-codex my/gptel-codex-model #'claude-opus-4.5)
          gptel-default-mode #'org-mode
          gptel-include-tool-results t
          gptel-backend (if use-codex
                            (gptel-make-openai "OpenAI")
                          (gptel-make-gh-copilot "Copilot"))))

  ;; Enable Macher for agentic tool use
  (macher-install)
  (macher-enable)

  ;; Toggle gptel-mode on existing org buffers (SPC o l t)
  (defun my/gptel-toggle-and-enable-solaire ()
    (interactive)
    (gptel-mode 'toggle)
    (solaire-mode 'toggle))
  (map! :leader
        :prefix ("o" . "open")
        (:prefix ("l" . "llm")
         :desc "Toggle gptel-mode and enable solaire-mode" "t" #'my/gptel-toggle-and-enable-solaire)))

(setq eca-chat-custom-model
      (if (my/wsl-p)
          my/eca-codex-model
        "github-copilot/claude-opus-4.5"))

(after! eca-chat
  (evil-set-initial-state 'eca-chat-mode 'normal)

  (map! :map eca-chat-mode-map
        ;; Normal mode - navigation
        :n "j" #'evil-next-line
        :n "k" #'evil-previous-line
        :n "gg" #'beginning-of-buffer
        :n "G" #'end-of-buffer
        :n "q" #'bury-buffer
        :n "gr" #'eca-chat-reset
        :n "gc" #'eca-chat-clear
        :n [return] #'eca-chat--key-pressed-return
        :n [tab] #'eca-chat--key-pressed-tab

        ;; Chat navigation
        :n "[[" #'eca-chat-go-to-prev-user-message
        :n "]]" #'eca-chat-go-to-next-user-message
        :n "[e" #'eca-chat-go-to-prev-expandable-block
        :n "]e" #'eca-chat-go-to-next-expandable-block
        :n "za" #'eca-chat-toggle-expandable-block

        ;; Tool call approval
        :n "ga" #'eca-chat-tool-call-accept-all
        :n "gA" #'eca-chat-tool-call-accept-next
        :n "gs" #'eca-chat-tool-call-accept-all-and-remember
        :n "gx" #'eca-chat-tool-call-reject-next

        ;; Chat management
        :n "gn" #'eca-chat-new
        :n "gf" #'eca-chat-select
        :n "gm" #'eca-chat-select-model
        :n "gb" #'eca-chat-select-behavior
        :n "gB" #'eca-chat-cycle-behavior
        :n "gR" #'eca-chat-rename
        :n "gh" #'eca-chat-timeline
        :n "g," #'eca-mcp-details
        :n "g." #'eca-transient-menu

        ;; Prompt operations
        :n "gp" #'eca-chat-repeat-prompt
        :n "gd" #'eca-chat-clear-prompt
        :n "gt" #'eca-chat-talk

        ;; Insert mode
        :i "S-<return>" #'eca-chat--key-pressed-newline
        :i "C-<up>" #'eca-chat--key-pressed-previous-prompt-history
        :i "C-<down>" #'eca-chat--key-pressed-next-prompt-history
        :i [return] #'eca-chat--key-pressed-return
        :i [tab] #'eca-chat--key-pressed-tab

        ;; Visual mode
        :v "y" #'evil-yank

        ;; Local leader
        :localleader
        :n "a" #'eca-chat-tool-call-accept-all
        :n "A" #'eca-chat-tool-call-accept-next
        :n "s" #'eca-chat-tool-call-accept-all-and-remember
        :n "r" #'eca-chat-tool-call-reject-next
        :n "n" #'eca-chat-new
        :n "f" #'eca-chat-select
        :n "m" #'eca-chat-select-model
        :n "b" #'eca-chat-select-behavior
        :n "B" #'eca-chat-cycle-behavior
        :n "R" #'eca-chat-rename
        :n "c" #'eca-chat-clear
        :n "k" #'eca-chat-reset
        :n "t" #'eca-chat-talk
        :n "h" #'eca-chat-timeline
        :n "," #'eca-mcp-details
        :n "." #'eca-transient-menu))

;; MCP details buffer
(after! eca-mcp
  (evil-set-initial-state 'eca-mcp-details-mode 'normal)

  (map! :map eca-mcp-details-mode-map
        :n "j" #'evil-next-line
        :n "k" #'evil-previous-line
        :n "gg" #'beginning-of-buffer
        :n "G" #'end-of-buffer
        :n "q" #'bury-buffer
        :n "gr" #'eca-mcp-details
        :n [return] #'push-button
        :n [tab] #'forward-button
        :n [backtab] #'backward-button
        :n "g," #'eca
        :n "g." #'eca-transient-menu))

(after! agent-shell
  ;; RET behavior: newline in insert mode, send in normal mode
  (evil-define-key 'insert agent-shell-mode-map (kbd "RET") #'newline)
  (evil-define-key 'normal agent-shell-mode-map (kbd "RET") #'comint-send-input)

  ;; MCP server configuration
  ;; (setq agent-shell-mcp-servers
  ;;       '(((name . "atlassian")
  ;;          (type . "http")
  ;;          (headers . [])
  ;;          (url . "https://mcp.atlassian.com/v1/sse"))))

  ;; Use Emacs state for diff buffers (agent-shell-diff)
  (add-hook 'diff-mode-hook
	    (lambda ()
	      (when (string-match-p "\\*agent-shell-diff\\*" (buffer-name))
		(evil-emacs-state)))))

(map! :after diff-mode
      :map diff-mode-map
      :localleader
      :desc "Apply buffer" "a" #'diff-apply-buffer)
