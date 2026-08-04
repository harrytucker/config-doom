(map! :after diff-mode
      :map diff-mode-map
      :localleader
      :desc "Apply buffer" "a" #'diff-apply-buffer)
