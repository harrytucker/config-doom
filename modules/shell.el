(after! eshell
  (require 'em-smart)
  (eshell-smart-initialize)
  (setq eshell-plain-echo-behavior t
        eshell-visual-commands '()))

(add-hook 'eshell-load-hook #'eat-eshell-mode)

(after! bash-completion
  (setq bash-completion-prog "/opt/homebrew/bin/bash"))
