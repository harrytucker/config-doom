(evil-set-undo-system 'undo-tree)

(after! projectile
  (add-to-list 'projectile-globally-ignored-directories "*vendor"))

(after! corfu
  (setq corfu-preselect 'prompt))
