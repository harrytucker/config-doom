;;; export-settings.el -*- lexical-binding: t; -*-

;; Shared Org HTML export configuration for the =html/org-export.css=/=.js=
;; theme. Loaded both from `modules/writing.org' (inside Doom, via
;; `after! org') and from `.github/scripts/publish.el' (plain `emacs --batch',
;; no Doom) so interactive exports and CI-published pages always match.
;; Deliberately uses `with-eval-after-load' rather than Doom's `after!' macro
;; so it works in both contexts.

(with-eval-after-load 'org
  (let ((html-dir (file-name-directory (or load-file-name buffer-file-name))))
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
          (concat (with-temp-buffer
                    (insert-file-contents
                     (concat html-dir "org-export-fonts.html"))
                    (buffer-string))
                  "<style>"
                  (with-temp-buffer
                    (insert-file-contents
                     (concat html-dir "org-export.css"))
                    (buffer-string))
                  "</style>"
                  "<script>"
                  (with-temp-buffer
                    (insert-file-contents
                     (concat html-dir "org-export.js"))
                    (buffer-string))
                  "</script>"))))
