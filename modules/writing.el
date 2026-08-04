(add-hook 'org-mode-hook #'auto-fill-mode)

;; Load Org's dependencies during idle time so the first Org buffer opens faster
(doom-load-packages-incrementally '(org))

(after! org
  (setq org-log-done 'time
        org-agenda-start-with-log-mode t
        org-hide-emphasis-markers t
        +org-capture-todo-file "Tasks.org"
        org-archive-location "::* Archive"
        org-agenda-files '("~/org"
                           "~/org/roam"
                           "~/org/roam/daily"))

  ;; Use pdf-tools for viewing exported PDFs
  (add-to-list 'org-file-apps '("\\.pdf\\'" . pdf-tools))

  ;; Larger heading fonts for visual hierarchy
  (custom-set-faces!
    '(org-level-1
      :height 1.2
      :inherit outline-1)
    '(org-level-2
      :height 1.1
      :inherit outline-2))

  ;; LaTeX export configuration
  (require 'ox-latex)
  (require 'ox-bibtex)

  ;; Use Tectonic as the LaTeX engine (self-contained, auto-fetches dependencies)
  (setq org-latex-pdf-process
        `(,(concat "tectonic --outdir=%o %f -Z search-path=" doom-user-dir "latex")))

  ;; Use engrave-faces for syntax-highlighted code blocks in LaTeX
  (setq org-latex-src-block-backend 'engraved)

  ;; Additional LaTeX packages for better tables and colours
  (setq org-latex-packages-alist '(("" "booktabs")
                                   ("" "tabularx")
                                   ("" "color")))

  ;; Custom 'mimore' document class for exports
  (add-to-list 'org-latex-classes
               '("mimore"
                 "\\documentclass{mimore}\n\[NO-DEFAULT-PACKAGES\]\n\[PACKAGES\]\n\[EXTRA\]"
                 ("\\section{%s}" . "\\section\*{%s}")
                 ("\\subsection{%s}" . "\\subsection\*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection\*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph\*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph\*{%s}")))
  (setq org-latex-default-class "mimore"))

(after! org
  (setq org-html-doctype "html5"
        org-html-html5-fancy t
        org-html-head-include-default-style nil
        org-html-preamble t
        org-html-preamble-format
        '(("en" "<div class=\"doc-header-inner\"><span><span class=\"doc-mark\">*</span><span class=\"doc-title\">%t</span></span><button id=\"theme-toggle\" type=\"button\" aria-label=\"Toggle dark mode\" title=\"Toggle dark mode\">&#9680;</button></div>"))
        org-html-postamble t
        org-html-postamble-format
        '(("en" "<p class=\"postamble\">Exported %T</p>"))
        org-html-htmlize-output-type 'inline-css
        org-html-head
        (concat "<style>"
                (with-temp-buffer
                  (insert-file-contents
                   (concat doom-user-dir "html/org-export.css"))
                  (buffer-string))
                "</style>"
                "<script>"
                (with-temp-buffer
                  (insert-file-contents
                   (concat doom-user-dir "html/org-export.js"))
                  (buffer-string))
                "</script>")))

(after! org-tree-slide
  (setq org-tree-slide-skip-outline-level 2)
  (org-tree-slide-presentation-profile))

(after! org-roam
  (setq org-roam-graph-link-hidden-types
        '("file" "http" "https")))

;; org-roam-ui talks to the browser over a websocket, so make sure the package
;; is loaded alongside org-roam
(after! org-roam
  (require 'websocket))

(after! org-roam-ui
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; NOTE: no label on :prefix — `SPC o` is already labelled "open" upstream, and
;; since Doom 635bc939 a labelled :prefix rebinds the prefix to a fresh keymap,
;; wiping every binding already there.
(map! :leader
      :prefix "o"
      :desc "Open calendar" "c" #'cfw:open-org-calendar)

(require 'auth-source)

(let ((credential (auth-source-user-and-password "api.github.com")))
  (setq grip-github-user (car credential)
        grip-github-password (cadr credential)))
