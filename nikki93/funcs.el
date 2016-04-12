(defun nikki93/flatten (x)
  (cond ((null x) nil)
        ((listp x) (append (nikki93/flatten (car x)) (nikki93/flatten (cdr x))))
        (t (list x))))

(defun eshell/ag (&rest args)
  (setq ag-highlight-search t)
  (compilation-start
   (mapconcat 'shell-quote-argument
              (append (list ag-executable
                            "--color" "--color-match" "30;43"
                            "--smart-case" "--nogroup" "--column" "--")
                      (nikki93/flatten args)) " ")
   'ag-mode))

(setq nikki93/cgame-path "/Users/nikki/Development/cgame/")
(setq nikki93/cgame-scratch-path (concat nikki93/cgame-path "/usr/scratch.lua"))

(defun nikki93/cgame-scratch (&optional start end)
  (interactive (if (use-region-p)
                   (list (region-beginning) (region-end))
                 (let* ((pos (point))
                        (search
                         (save-excursion
                           (list (if (save-match-data (looking-at "^function[ \t]"))
                                     (point) ; already at start
                                   (end-of-line)
                                   (lua-beginning-of-proc)
                                   (if (= pos (point))
                                       (1+ pos) ; should have moved back
                                     (point)))
                                 (progn (lua-end-of-proc) (point))))))
                   (if (and (>= pos (car search)) (< pos (cadr search)))
                       search       ; we are in a function definition!
                     (save-excursion    ; we're not, just send current line
                       (list (progn (backward-paragraph) (1+ (point)))
                             (progn (forward-paragraph) (point))))))))

  (let ((overlay (make-overlay start end)))
    (overlay-put overlay 'face 'secondary-selection)
    (run-with-timer 0.2 nil 'delete-overlay overlay))

  (let ((scratch-path nikki93/cgame-scratch-path)   ; save buffer-local value
        (buf (current-buffer))
        (n (count-lines 1 start)))
    (with-temp-buffer
      (insert "--[[" (or (buffer-file-name buf) "unknown") "--]]")
      (while (> n 0) (insert "\n") (setq n (- n 1)))
      (insert-buffer-substring buf start end)
      (write-file scratch-path))))

(defun nikki93/exponent-scratch (start end)
  (interactive "r")
  (setq comint-process-echoes nil)

  (setq curwindow (selected-window))
  (save-excursion (let ((jscode (concat ":multi\n" (buffer-substring start end) "\n:end")))
                    (set-buffer "*repl.sh*")
                    (insert jscode)
                    (comint-send-input)))
  (select-window curwindow))
