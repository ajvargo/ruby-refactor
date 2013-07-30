;;; ruby-refactor.el --- A minor mode for Emacs that presents various Ruby refactoring helpers.

;; Copyright (C) 2013 Andrew J Vargo

;; Author: Andrew J Vargo <ajvargo@gmail.com>
;; Keywords: refactor ruby
;; Version: 0.1
;; URL: https://github.com/ajvargo/ruby-refactor
;; Package-Requires: ((ruby-mode "1.2"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Ruby refactor is inspired by the Vim plugin vim-refactoring-ruby,
;; currently found at https://github.com/ecomba/vim-ruby-refactoring.

;; I've implemented 5 refactorings
;;  - Extract to Method
;;  - Extract Local Variable
;;  - Extract Constant
;;  - Add Parameter
;;  - Extract to Let

; ## Install
;; Add this file to your load path.
;; (require 'ruby-refactor)


;; ## Extract to Method:
;; Select a region of text and invoke 'ruby-refactor-extract-to-method'.
;; You'll be prompted for a method name. The method will be created
;; above the method you are in with the method contents being the
;; selected region. The region will be replaced w/ a call to method.

;; ## Extract Local Variable:
;; Select a region of text and invoke `ruby-refactor-extract-local-variable`.
;; You'll be prompted for a variable name.  The new variable will
;; be created directly above the selected region and the region
;; will be replaced with the variable.

;; ## Extract Constant:
;; Select a region of text and invoke `ruby-refactor-extract-contant`.
;; You'll be prompted for a constant name.  The new constant will
;; be created at the top of the enclosing class or module directly
;; after any include or extend statements and the regions will be
;; replaced with the constant.

;; ## Add Parameter:
;; 'ruby-refactor-add-parameter'
;; This simply prompts you for a parameter to add to the current
;; method definition. If you are on a text, you can just hit enter
;; as it will use it by default. There is a custom variable to set
;; if you like parens on your params list.  Default values and the
;; like shouldn't confuse it.

;; ## Extract to Let:
;; This is really for use with RSpec

;; 'ruby-refactor-extract-to-let'
;; There is a variable for where the 'let' gets placed. It can be
;; "top" which is top-most in the file, or "closest" which just
;; walks up to the first describe/context it finds.
;; You can also specify a different regex, so that you can just
;; use "describe" if you want.
;; If you are on a line:
;;   a = Something.else.doing
;;     becomes
;;   let(:a){ Something.else.doing }

;; If you are selecting a region:
;;   a = Something.else
;;   a.stub(:blah)
;;     becomes
;;   let :a do
;;     _a = Something.else
;;     _a.stub(:blah)
;;     _a
;;   end

;; In both cases, you need the line, first line to have an ' = ' in it,
;; as that drives conversion.

;; There is also the bonus that the let will be placed *after* any other
;; let statements. It appends it to bottom of the list.

;; Oh, if you invoke with a prefix arg (C-u, etc.), it'll swap the placement
;; of the let.  If you have location as top, a prefix argument will place
;; it closest.  I kinda got nutty with this one.


;; ## TODO
;; From the vim plugin, these remain to be done (I don't plan to do them all.)
;;  - remove inline temp (sexy!)
;;  - convert post conditional


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Customizations
(defgroup ruby-refactor nil
  "Refactoring helpers for Ruby."
  :version "0.1"
  :group 'files)

(defcustom ruby-refactor-let-prefix ""
  "Prefix to use when extracting a region to let"
  :group 'ruby-refactor
  :type 'string
)

(defcustom ruby-refactor-add-parens nil
  "Add parens when adding a parameters to a function. Will be converted if params already exist"
  :group 'ruby-refactor
  :type 'boolean
  )

(defcustom ruby-refactor-trim-re "[ \t\n]*"
  "Regex to use for trim functions. Will be applied to both front and back of string"
  :group 'ruby-refactor
  :type 'string
)

(defcustom ruby-refactor-let-placement-re "^[ \t]*\\(describe\\|context\\)"
  "Regex searched for to determine where to put let statemement.
See `ruby-refactor-let-position' to specify proximity to assignment
being altered."
  :group 'ruby-refactor
  :type 'string
)

(defcustom ruby-refactor-let-position 'top
  "Where to place 'let' statement. 'closest places it after the
most recent context or describe.  'top (default) places it after
 opening describe "
  :type '(choice (const :tag "place top-most" top)
                 (const :tag "place closest" closest)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Vars
(defvar ruby-refactor-mode-map nil
  "Keymap to use in ruby refactor minor mode.")

(defvar ruby-refactor-mode-hook nil
  "Hooks run during mode start")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Helper functions
(defun ruby-refactor-line-contains-equal-p (line)
  "Returns if line contains an '='"
  (string-match "=" line))

(defun ruby-refactor-line-has-let-p ()
  "Returns if line contains 'let('"
  (string-match "let(" (thing-at-point 'line)))

(defun ruby-refactor-ends-with-newline-p (region-start region-end)
  "Returns if the last character is a newline ignoring trailing spaces"
  (let ((text (replace-regexp-in-string " *$" "" (buffer-substring-no-properties region-start region-end))))
    (string-match "\n" (substring text -1))))

(defun ruby-refactor-trim-string (string)
  "Trims text from both front and back of a string"
   (replace-regexp-in-string (concat ruby-refactor-trim-re "$") ""
                             (replace-regexp-in-string (concat "^" ruby-refactor-trim-re) "" string)))

(defun ruby-refactor-trim-newline-endings (string)
  "Trims newline off front and back of string"
  (replace-regexp-in-string "\\(^\n\\|\n$\\)" "" string))

(defun ruby-refactor-trim-list (list)
  "Applies `ruby-refactor-trim-string' to each item in list, and returns newly trimmed list"
  (mapcar #'ruby-refactor-trim-string list))

(defun ruby-refactor-goto-def-start ()
  "Moves point to start of first def to appear previously "
  (search-backward-regexp "^\\s *def"))

(defun ruby-refactor-goto-first-non-let-line ()
  "Place point at beginning of first non let( containing line"
  (while (ruby-refactor-line-has-let-p)
    (forward-line 1)))

(defun ruby-refactor-goto-constant-insertion-point ()
  "Moves point to the proper location to insert a constant at the top of a class or module"
  (search-backward-regexp "^ *\\<class\\|^ *module\\>")
  (next-line)
  (while (or (string-match "include" (thing-at-point 'line))
             (string-match "extend" (thing-at-point 'line)))
    (next-line)))

(defun ruby-refactor-jump-to-let-insert-point (flip-location)
  "Positions point at the proper place for inserting let.
This depends the value of `ruby-refactor-let-position'"
  (let ((position-test (if (null flip-location)
                           #'(lambda(left right)(eq left right))
                         #'(lambda(left right)(not (eq left right))))))
    (cond ((funcall position-test 'top ruby-refactor-let-position)
           (goto-char 0)
           (search-forward-regexp ruby-refactor-let-placement-re))
          ((funcall position-test 'closest ruby-refactor-let-position)
           (search-backward-regexp ruby-refactor-let-placement-re)))))

(defun ruby-refactor-get-input-with-default (prompt default-value)
  "Gets user input with a default value"
  (list (read-string (format "%s (%s): " prompt default-value) nil nil default-value)))

(defun ruby-refactor-new-params (existing-params new-variable)
  "Appends or creates parameter list, doing the right thing for parens"
  (let ((param-list (mapconcat 'identity
                      (ruby-refactor-trim-list (remove "" (append (split-string existing-params ",") (list new-variable))))
                      ", " )))
    (if ruby-refactor-add-parens
        (format "(%s)" param-list)
      (format " %s" param-list))))

(defun ruby-refactor-assignement-error-message ()
  "Message user with error if the (first) line of a let
extraction is missing."
  (message "First line needs to have an assigment"))

(defun ruby-refactor-extract-line-to-let (flip-location)
  "Extracts current line to let."
  (let* ((line-bounds (bounds-of-thing-at-point 'line))
         (text-begin (car line-bounds))
         (text-end (cdr line-bounds))
         (text (ruby-refactor-trim-newline-endings (buffer-substring-no-properties text-begin text-end)))
         (line-components (ruby-refactor-trim-list (split-string text " = "))))
    (if (ruby-refactor-line-contains-equal-p text)
        (progn
          (delete-region text-begin text-end)
          (ruby-refactor-jump-to-let-insert-point flip-location)
          (forward-line 1)
          (ruby-refactor-goto-first-non-let-line)
          (ruby-indent-line)
          (insert (format "let(:%s){ %s }\n" (car line-components) (cadr line-components)))
          (newline-and-indent)
          (beginning-of-line)
          (unless (looking-at "^[ \t]*$") (newline-and-indent))
          (delete-blank-lines))
      (ruby-refactor-assignement-error-message))))

(defun ruby-refactor-extract-region-to-let (flip-location)
  "Extracts current region to let."
  (let* ((text-begin (region-beginning))
        (text-end (region-end))
        (text (ruby-refactor-trim-newline-endings (buffer-substring-no-properties text-begin text-end)))
        (text-lines (ruby-refactor-trim-list (split-string text "\n"))))
        (if (ruby-refactor-line-contains-equal-p (car text-lines))
            (let* ((variable-name (car (ruby-refactor-trim-list (split-string (car text-lines) " = "))))
                  (faux-variable-name (concat ruby-refactor-let-prefix variable-name))
                  (case-fold-search nil))
              (delete-region text-begin text-end)
              (ruby-refactor-jump-to-let-insert-point flip-location)
              (forward-line 1)
              (ruby-refactor-goto-first-non-let-line)
              (ruby-indent-line)
              (insert (format "let :%s do" variable-name))
              (mapc #'(lambda(line)
              (newline)
              (insert (replace-regexp-in-string variable-name faux-variable-name line)))
                    text-lines)
              (insert "\n" faux-variable-name "\n" "end")
              (newline-and-indent)
              (search-backward "let")
              (ruby-indent-exp)
              (search-forward "end")
              (newline-and-indent)
              (beginning-of-line)
              (unless (looking-at "^[ \t]*$") (newline-and-indent))
              (delete-blank-lines))
          (ruby-refactor-assignement-error-message))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; API
(defun ruby-refactor-extract-to-method (region-start region-end)
  "Extracts region to method"
  (interactive "r")
  (save-restriction
    (save-match-data
      (widen)
      (let ((ends-with-newline (ruby-refactor-ends-with-newline-p region-start region-end))
            (function-guts (ruby-refactor-trim-newline-endings (buffer-substring-no-properties region-start region-end)))
            (function-name (read-from-minibuffer "Method name? ")))
        (delete-region region-start region-end)
        (ruby-indent-line)
        (insert function-name)
        (if ends-with-newline
            (progn
              (ruby-indent-line)
              (insert "\n")
              (ruby-indent-line)))
        (ruby-refactor-goto-def-start)
        (insert "def " function-name "\n" function-guts "\nend\n\n")
        (ruby-refactor-goto-def-start)
        (indent-region (point)
                       (progn
                         (forward-paragraph)
                         (point)))
        (search-forward function-name)
        (backward-sexp)
        ))))

(defun ruby-refactor-add-parameter (variable-name)
  "Add a parameter to the method point is in"
  (interactive (ruby-refactor-get-input-with-default "Variable name" (thing-at-point 'symbol)))
  (save-excursion
    (save-restriction
      (save-match-data
        (widen)
        (ruby-refactor-goto-def-start)
        (search-forward "def")
        (let* ((params-start-point (search-forward-regexp (concat ruby-symbol-re "+")))
              (params-end-point (line-end-position))
              (params-string (buffer-substring-no-properties params-start-point params-end-point)))
          (delete-region params-start-point params-end-point)
          (goto-char params-start-point)
          (insert (ruby-refactor-new-params params-string variable-name))
          )))))

(defun ruby-refactor-extract-to-let(&optional flip-location)
  "Converts initialization on current line to 'let', ala RSpec
When called with a prefix argument, flips the default location
for placement.
If a region is selected, the first line needs to have an assigment.
The let style is then a do block containing the region.
If a region is not selected, the transformation uses the current line."
  (interactive "P")
  (save-excursion
    (save-restriction
      (save-match-data
        (widen)
        (if (region-active-p)
            (ruby-refactor-extract-region-to-let flip-location)
          (ruby-refactor-extract-line-to-let flip-location))))))

(defun ruby-refactor-extract-local-variable()
  "Extracts selected text to local variable"
  (interactive)
  (save-restriction
    (save-match-data
      (widen)
      (let* ((text-begin (region-beginning))
             (text-end (region-end))
             (text (ruby-refactor-trim-newline-endings (buffer-substring-no-properties text-begin text-end)))
             (variable-name (read-from-minibuffer "Variable name? ")))
        (delete-region text-begin text-end)
        (insert variable-name)
        (beginning-of-line)
        (open-line 1)
        (ruby-indent-line)
        (insert variable-name " = " text)
        (search-forward variable-name)
        (backward-sexp)))))

(defun ruby-refactor-extract-constant()
  "Extracts selected text to a constant at the top of the current class or module"
  (interactive)
  (save-restriction
    (save-match-data
      (widen)
      (let* ((text-begin (region-beginning))
             (text-end (region-end))
             (text (ruby-refactor-trim-newline-endings (buffer-substring-no-properties text-begin text-end)))
             (constant-name (read-from-minibuffer "Constant name? ")))
        (delete-region text-begin text-end)
        (insert constant-name)
        (ruby-refactor-goto-constant-insertion-point)
        (beginning-of-line)
        (open-line 2)
        (next-line)
        (ruby-indent-line)
        (insert constant-name " = " text "\n")
        (search-forward constant-name)
        (backward-sexp)))))

(defun ruby-refactor-remove-inline-temp()
  "Replaces temporary variable with direct call to method"
  (interactive)
  (message "Not Yet Implmented"))

(defun ruby-refactor-convert-post-conditional()
  "Convert post conditional expression to conditional expression"
  (interactive)
  (message "Not Yet Implmented"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Official setup and the like
(defun ruby-refactor-mode-launch ()
  (ruby-refactor-mode 1))

(defun ruby-refactor-start ()
  (use-local-map ruby-refactor-mode-map)
  (message "Ruby-Refactor mode enabled"))

(defun ruby-refactor-stop ()
  (message "Ruby-Refactor mode disabled"))

(unless ruby-refactor-mode-map
  (setq ruby-refactor-mode-map (make-sparse-keymap))
  (define-key ruby-refactor-mode-map (kbd "C-c C-r e") 'ruby-refactor-extract-to-method)
  (define-key ruby-refactor-mode-map (kbd "C-c C-r p") 'ruby-refactor-add-parameter)
  (define-key ruby-refactor-mode-map (kbd "C-c C-r l") 'ruby-refactor-extract-to-let)
  (define-key ruby-refactor-mode-map (kbd "C-c C-r v") 'ruby-refactor-extract-local-variable)
  (define-key ruby-refactor-mode-map (kbd "C-c C-r c") 'ruby-refactor-extract-constant))

(define-minor-mode ruby-refactor-mode
  "Ruby Refactor minor mode"
  :global nil
  :group 'ruby-refactor
  :keymap ruby-refactor-mode-map
  :lighter " RubyRef"
  (if ruby-refactor-mode
      (progn
        (use-local-map ruby-refactor-mode-map)
        (run-hooks 'ruby-refactor-mode-hook)
      (ruby-refactor-start))
    (progn
      (use-local-map nil)
      (ruby-refactor-stop))))

(add-hook 'ruby-mode-hook 'ruby-refactor-mode-launch)

(provide 'ruby-refactor)

;;; ruby-refactor.el ends here
