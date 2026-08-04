(after! sql-mode
  (sql-set-product 'postgres)
  (add-hook 'sql-mode-hook #'apheleia-mode)
  (set-formatter!
    'pg_format '("pg_format"
                 "--comma-break"
                 "--keep-newline"
                 "-")
    :modes '(sql-mode)))

(delete 'sql-mode +format-on-save-disabled-modes)

(after! pgmacs
  (evil-set-initial-state 'pgmacs-mode 'normal)

  ;; Suppress conflicting single-key bindings
  (dolist (key '("j" "k" "h" "d" "u" "i" "p" "g" "r" "v" "y"))
    (define-key pgmacs-table-list-map (kbd key) nil)
    (define-key pgmacs-table-list-map/table (kbd key) nil)
    (define-key pgmacs-row-list-map (kbd key) nil)
    (define-key pgmacs-row-list-map/table (kbd key) nil)
    (define-key pgmacs-proc-list-map (kbd key) nil))

  ;; Table list buffer (main database view)
  (evil-define-key* 'normal pgmacs-table-list-map
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "l" #'pgmacstbl-next-column
    "h" #'pgmacstbl-previous-column
    "gg" #'beginning-of-buffer
    "G" #'end-of-buffer
    "q" #'bury-buffer
    "gr" #'pgmacs--table-list-redraw
    "?" #'pgmacs--table-list-help
    "go" #'pgmacs-open-table
    "gp" #'pgmacs--display-procedures
    "e" #'pgmacs-run-sql
    "E" #'pgmacs-run-buffer-sql
    "=" #'pgmacs--shrink-columns
    "r" #'pgmacs--redraw-pgmacstbl
    "gT" #'pgmacs--switch-to-database-buffer
    (kbd "TAB") #'pgmacs--next-item)

  ;; Table list buffer when point is on a table
  (evil-define-key* 'normal pgmacs-table-list-map/table
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "l" #'pgmacstbl-next-column
    "h" #'pgmacstbl-previous-column
    (kbd "RET") #'pgmacs--table-list-RET
    "D" #'pgmacs--table-list-delete
    "gS" #'pgmacs--schemaspy-database
    "gR" #'pgmacs--table-list-rename
    "gj" #'pgmacs--row-as-json
    "gv" #'pgmacs--view-value
    "<" (lambda () (interactive)
          (text-property-search-backward 'pgmacstbl)
          (forward-line))
    ">" (lambda () (interactive)
          (text-property-search-forward 'pgmacstbl)
          (forward-line -1))
    "g0" (lambda () (interactive) (pgmacstbl-goto-column 0))
    "g1" (lambda () (interactive) (pgmacstbl-goto-column 1))
    "g2" (lambda () (interactive) (pgmacstbl-goto-column 2))
    "g3" (lambda () (interactive) (pgmacstbl-goto-column 3))
    "g4" (lambda () (interactive) (pgmacstbl-goto-column 4))
    "g5" (lambda () (interactive) (pgmacstbl-goto-column 5))
    "g6" (lambda () (interactive) (pgmacstbl-goto-column 6))
    "g7" (lambda () (interactive) (pgmacstbl-goto-column 7))
    "g8" (lambda () (interactive) (pgmacstbl-goto-column 8))
    "g9" (lambda () (interactive) (pgmacstbl-goto-column 9)))

  ;; Row list buffer (viewing table contents)
  (evil-define-key* 'normal pgmacs-row-list-map
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "l" #'pgmacstbl-next-column
    "h" #'pgmacstbl-previous-column
    "gg" #'beginning-of-buffer
    "G" #'end-of-buffer
    "q" #'bury-buffer
    "?" #'pgmacs--row-list-help
    "I" #'pgmacs--insert-row-empty
    "go" #'pgmacs-open-table
    "r" #'pgmacs--redraw-pgmacstbl
    "gr" #'pgmacs--row-list-redraw
    "e" #'pgmacs-run-sql
    "E" #'pgmacs-run-buffer-sql
    "gW" #'pgmacs--add-where-filter
    "gS" #'pgmacs--schemaspy-table
    "gT" #'pgmacs--switch-to-database-buffer
    (kbd "TAB") #'pgmacs--next-item)

  ;; Row list buffer when point is on a row (editing mode)
  (evil-define-key* 'normal pgmacs-row-list-map/table
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "l" #'pgmacstbl-next-column
    "h" #'pgmacstbl-previous-column
    (kbd "RET") #'pgmacs--row-list-dwim
    "w" #'pgmacs--edit-value-widget
    "!" #'pgmacs--shell-command-on-value
    "&" #'pgmacs--async-command-on-value
    "gU" #'pgmacs--upcase-value
    "gu" #'pgmacs--downcase-value
    "g~" #'pgmacs--capitalize-value
    "gv" #'pgmacs--view-value
    "dd" #'pgmacs--row-list-delete-row
    "x" #'pgmacs--row-list-delete-marked
    (kbd "DEL") #'pgmacs--row-list-delete-row
    "gR" #'pgmacs--row-list-rename-column
    "a" #'pgmacs--insert-row
    "gi" #'pgmacs--insert-row-widget
    "yy" #'pgmacs--copy-row
    "p" #'pgmacs--yank-row
    "=" #'pgmacs--shrink-columns
    "gj" #'pgmacs--row-as-json
    "m" #'pgmacs--row-list-mark-row
    "u" #'pgmacs--row-list-unmark-row
    "U" #'pgmacs--row-list-unmark-all
    "<" (lambda () (interactive)
          (text-property-search-backward 'pgmacstbl)
          (forward-line))
    ">" (lambda () (interactive)
          (text-property-search-forward 'pgmacstbl)
          (forward-line -1))
    "g0" (lambda () (interactive) (pgmacstbl-goto-column 0))
    "g1" (lambda () (interactive) (pgmacstbl-goto-column 1))
    "g2" (lambda () (interactive) (pgmacstbl-goto-column 2))
    "g3" (lambda () (interactive) (pgmacstbl-goto-column 3))
    "g4" (lambda () (interactive) (pgmacstbl-goto-column 4))
    "g5" (lambda () (interactive) (pgmacstbl-goto-column 5))
    "g6" (lambda () (interactive) (pgmacstbl-goto-column 6))
    "g7" (lambda () (interactive) (pgmacstbl-goto-column 7))
    "g8" (lambda () (interactive) (pgmacstbl-goto-column 8))
    "g9" (lambda () (interactive) (pgmacstbl-goto-column 9)))

  ;; Procedure list buffer
  (evil-define-key* 'normal pgmacs-proc-list-map
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "l" #'pgmacstbl-next-column
    "h" #'pgmacstbl-previous-column
    "gg" #'beginning-of-buffer
    "G" #'end-of-buffer
    "q" #'bury-buffer
    "?" #'pgmacs--proc-list-help
    (kbd "RET") #'pgmacs--proc-list-RET
    (kbd "TAB") #'pgmacs--next-item
    "dd" #'pgmacs--proc-list-delete
    "gT" #'pgmacs--switch-to-database-buffer
    "gR" #'pgmacs--proc-list-rename
    "<" (lambda () (interactive)
          (text-property-search-backward 'pgmacstbl)
          (forward-line))
    ">" (lambda () (interactive)
          (text-property-search-forward 'pgmacstbl)
          (forward-line -1)))

  ;; Transient buffer (query results)
  (evil-define-key* 'normal pgmacs-transient-map
    "j" #'evil-next-line
    "k" #'evil-previous-line
    "gg" #'beginning-of-buffer
    "G" #'end-of-buffer
    "q" #'bury-buffer
    "go" #'pgmacs-open-table
    "e" #'pgmacs-run-sql
    "E" #'pgmacs-run-buffer-sql
    "gT" #'pgmacs--switch-to-database-buffer)

  ;; Paginated buffer (large tables)
  (evil-define-key* 'normal pgmacs-paginated-map
    "]p" #'pgmacs--paginated-next
    "[p" #'pgmacs--paginated-prev))

(after! lsp-eslint
  (setq lsp-eslint-auto-fix-on-save t))

(let ((fnm-node-bin (expand-file-name "~/.local/share/fnm/aliases/default/bin")))
  (when (file-directory-p fnm-node-bin)
    (setenv "PATH" (concat fnm-node-bin ":" (getenv "PATH")))
    (add-to-list 'exec-path fnm-node-bin)))

(after! rustic
  (setq lsp-rust-server 'rust-analyzer
        lsp-rust-analyzer-proc-macro-enable t
        lsp-rust-analyzer-cargo-run-build-scripts t
        rustic-indent-offset 4))

(add-hook 'python-mode-hook #'python-docstring-mode)

(after! python
  (set-formatter! 'ruff :modes '(python-mode python-ts-mode)))

(after! go-mode
  (setq go-ts-mode-indent-offset 4))

(add-to-list 'auto-mode-alist '("\\.puml\\'" . plantuml-mode))
