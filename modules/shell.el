(after! eshell
  (require 'em-smart)
  (eshell-smart-initialize)
  (setq eshell-plain-echo-behavior t
        eshell-visual-commands '()))

(add-hook 'eshell-load-hook #'eat-eshell-mode)
