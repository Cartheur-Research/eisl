 
(import "formula")

(defun cadr (x)
    (car (cdr x)))

(defun val (x)
    (car x))

(defun rest (x)
    (cdr x))

(defun mexp ()
  (initialize)
  (repl))

(defun repl ()
  (block repl
    (cond ((catch 'exit
             (for ((s (val (parse nil 'stdin)) (val (parse nil 'stdin))))
                  ((equal s '(quit)) (return-from repl t))
                  (if (and (consp s)(eq (elt s 0) 'load))
                      (format (standard-output) "~A~%" (ignore-errors (load* (elt s 1))))
                      (format (standard-output) "~A~%" (ignore-errors (eval s))))
                  (prompt))) t)
          (t (prompt)(repl)))))


(defun initialize ()
  (format (standard-output) "Meta expression translater~%")
  (prompt))


(defun prompt ()
  (format (standard-output) "M> "))


(defun error* (msg arg)
  (format (standard-output) msg)
  (format (standard-output) "~A" arg)
  (format (standard-output) "~%")
  (if (not (eq input-stream (standard-input)))
      (close input-stream))
  (setq input-stream (standard-input))
  (throw 'exit nil))


(defun parse (buffer stream)
    (cond ((null buffer) (cond ((eq stream 'stdin) (parse (tokenize (read-line)) stream))
                               ((eq stream 'filein) t)))
          ;; list [1;2;3]                    
          ((string= (car buffer) "[") (parse-bracket (cdr buffer) stream))
          ;; function e.g. sin[x] or difinition e.g. foo[x] = x
          ((and (> (length buffer) 1) (string= (cadr buffer) "["))
           (let* ((result0 (parse-bracket (cdr (cdr buffer)) stream nil))
                  (fn (make-symbol (car buffer)))
                  (arg (val result0))
                  (buffer* (rest result0)))
                    (cond ((and (> (length buffer*) 1) (string= (car buffer*) "="))
                          ;; difinition e.g. foo[x]=x
                           (let* ((result1 (parse (cdr buffer*) stream))
                                  (exp (val result1))
                                  (buffer** (rest result1)))
                              (cons (cons 'defun (list fn arg exp)) buffer**)))  
                          ;; function s.g. sin[x]
                          (t (cons (cons fn arg) buffer*)))))
          ;; formula 
          (t (cons (infix->prefix (string->infix (car buffer))) (cdr buffer)))))



(defun parse-bracket (buffer stream res)
    (cond ((null buffer) (cond ((eq stream 'stdin) (parse (tokenize (read-line)) stream))
                               ((eq stream 'filein) t)))
          ((string= (car buffer) "]") (cons (reverse res) (cdr buffer)))
          ((string= (car buffer) ";") (parse-bracket (cdr buffer) stream res))
          (t (let ((result (parse buffer stream)))
                (parse-bracket (rest result) stream (cons (val result) res))))))


(defun make-symbol (str)
  (convert (to-upper-string (convert str <list>)) <symbol>))


(defun to-upper-string (ls)
  (if (null ls)
      ""
      (string-append (convert (to-upper (car ls)) <string>)
                     (to-upper-string (cdr ls)))))


(defun to-upper (x)
  (let ((ascii (convert x <integer>)))
    (if (and (>= ascii 97)(<= ascii 122))
        (convert (- ascii 32) <character>)
        x)))


(defun tokenize (x)
    (tokenize1 (convert x <list>) "" nil))

(defun tokenize1 (ls token res)
    (cond ((null ls) (if (string= token "") 
                         (reverse res)
                         (reverse (cons token res))))
          ((char= (car ls) #\space) (tokenize1 (cdr ls) token res))
          ((delimiter-p (car ls)) (if (string= token "")
                                      (tokenize1 (cdr ls)
                                                 ""
                                                 (cons (convert (car ls) <string>) res))
                                      (tokenize1 (cdr ls)
                                                 ""
                                                 (cons (convert (car ls) <string>) (cons token res)))))
          (t (tokenize1 (cdr ls) (string-append token (convert (car ls) <string>)) res))))

(defun delimiter-p (x)
    (or (char= x #\[)
        (char= x #\])
        (char= x #\()
        (char= x #\))
        (char= x #\=)
        (char= x #\,)
        (char= x #\;)))


