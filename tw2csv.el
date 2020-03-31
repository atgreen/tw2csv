#!/usr/bin/emacs --script

;; Copyright (c) 2020  Anthon Green <green@redhat.com>
;;
;; See LICENSE for copying information.

(defun tw/find-next (arg)
  (save-excursion
    (search-forward arg nil nil nil)
    (buffer-substring-no-properties (point) (line-end-position))))

(defun tripwire-to-csv ()
  "Convert a tripwire ASCII report to CSV"
  (interactive)
  (let ((policy (tw/find-next "Policy Name: "))
	(test (tw/goto-next-test)))
    (while test
      (let ((rule (tw/find-last-rule))
	    (status (tw/find-next "Status: ")))
	(append-to-file (concat policy "\t" rule "\t" test "\t" status "\n")
			nil "/dev/stdout"))
      (setq test (tw/goto-next-test)))))

(defun tw/find-last-rule ()
  (save-excursion
    (search-backward "Rule Name: " nil nil nil)
    (right-char 11)
    (buffer-substring-no-properties (point) (line-end-position))))

(defun tw/goto-next-test ()
  (let ((mark (search-forward "Test Name: " nil t nil)))
    (if mark
	(buffer-substring-no-properties (point) (line-end-position))
      nil)))

(let ((report-file (make-temp-file "tw2csv")))
  (if (= (length command-line-args) 4)
      (progn
	(shell-command (concat "pdftotext " (car (last command-line-args)) " " report-file))
	(find-file report-file)
	(tripwire-to-csv))
    (error "Missing PDF argument")))
