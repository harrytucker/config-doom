;;; publish.el --- build the Org HTML site for GitHub Pages -*- lexical-binding: t; -*-

;; Run with: emacs --batch -l .github/scripts/publish.el
;; Expects to be run from the repository root. Not part of the Doom runtime —
;; a standalone batch script used only by the GitHub Actions Pages workflow.

(require 'package)
(setq package-user-dir (expand-file-name ".github/scripts/.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                          ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'htmlize)
  (package-install 'htmlize))

(require 'ox-html)

(load (expand-file-name "html/export-settings.el"))

(setq org-html-link-org-files-as-html t
      org-export-with-section-numbers nil
      org-export-with-toc nil)

(setq org-publish-project-alist
      `(("doom-config-root"
         :base-directory ,default-directory
         :base-extension "org"
         :recursive nil
         :publishing-directory ,(expand-file-name "public/" default-directory)
         :publishing-function org-html-publish-to-html)
        ("doom-config-modules"
         :base-directory ,(expand-file-name "modules/" default-directory)
         :base-extension "org"
         :recursive nil
         :publishing-directory ,(expand-file-name "public/modules/" default-directory)
         :publishing-function org-html-publish-to-html)
        ("doom-config" :components ("doom-config-root" "doom-config-modules"))))

(org-publish-project "doom-config" t)
