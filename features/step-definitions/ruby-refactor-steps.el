
(When "^I go to character \"\\(.+\\)\"$"
  (lambda (char)
    (goto-char (point-min))
    (let ((search (re-search-forward (format "%s" char) nil t))
          (message "Can not go to character '%s' since it does not exist in the current buffer: %s"))
      (cl-assert search nil message char (espuds-buffer-contents)))))

(When "^I go to the \\(front\\|end\\) of the word \"\\(.+\\)\"$"
  (lambda (pos word)
    (goto-char (point-min))
    (let ((search (re-search-forward (format "%s" word) nil t))
          (message "Can not go to character '%s' since it does not exist in the current buffer: %s"))
      (cl-assert search nil message word (espuds-buffer-contents))
      (if (string-equal "front" pos) (backward-word)))))


(Given "^I have loaded my example Ruby file$"
  (lambda ()
    (insert-file-contents "features/example.rb")
    ))

(When "^I select:$"
  (lambda (text)
    (goto-char (point-min))
    (let ((search (re-search-forward text nil t)))
      (cl-assert search nil "The text '%s' was not found in the current buffer." text))
    (set-mark (point))
    (re-search-backward text)))
