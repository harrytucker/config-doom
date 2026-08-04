(map! :after diff-mode
      :map diff-mode-map
      :localleader
      :desc "Apply buffer" "a" #'diff-apply-buffer)

(after! mise
  (setq mise-update-on-eshell-directory-change t))
(add-hook 'after-init-hook #'global-mise-mode)
