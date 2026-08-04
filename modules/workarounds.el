(when (featurep :system 'macos)
  (map! :i "M-3" #'(lambda () (interactive) (insert "#")))
  (setq Man-sed-command "gsed")

  (after! bash-completion
    (setq bash-completion-prog "/opt/homebrew/bin/bash")))
