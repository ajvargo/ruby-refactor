(let* ((current-directory (file-name-directory load-file-name))
       (features-directory (expand-file-name ".." current-directory))
       (project-directory (expand-file-name ".." features-directory)))
  (setq ruby-refactor-root-path project-directory))

(add-to-list 'load-path ruby-refactor-root-path)

(require 'ruby-refactor)
(require 'espuds)
(require 'ert)

(Before
 (global-set-key (kbd "C-c C-r e") 'ruby-refactor-extract-to-method)
 (global-set-key (kbd "C-c C-r p") 'ruby-refactor-add-parameter)
 (global-set-key (kbd "C-c C-r l") 'ruby-refactor-extract-to-let)
 (switch-to-buffer
  (get-buffer-create "*ruby-refactor*"))
 (erase-buffer)
 (fundamental-mode)
 (transient-mark-mode 1)
 (cua-mode 0)
 (setq set-mark-default-inactive nil)
 (deactivate-mark))

(After)
