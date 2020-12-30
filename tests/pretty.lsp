;; プリティ−プリンタ
;; pretty printer for ISLisp
;;written by kenichi sasagawa

(defconstant width 100)
(defconstant long 15)
(defglobal buffer nil)
(defglobal input-stream (standard-input))
(defglobal output-stream (standard-output))


;; write formated code to **.tmp file
(defun formatter (file)
  (let ((exp nil)
        (output (string-append (filename file) ".tmp")))
    (setq input-stream (open-input-file file))
    (setq output-stream (open-output-file output))
    (setq exp (sexp-read))
    (while (not (end-of-file-p exp))
           (pp1 exp 0)
           ;(print exp)
           (setq exp (sexp-read)))
    (close input-stream)
    (setq input-stream (standard-input))
    (setq output-stream (standard-output))
    t))

(defun filename (str)
  (if (eql (substring str 0 0) ".")
      (filename2 str)
      (filename1 str)))

(defun filename1 (str)
  (let* ((n (char-index #\. str)))
    (if (null n)
        (error* "lack of filename ext" str))
    (substring str 0 (- n 1))))

;; e.g. ./example/test.lsp 
(defun filename2 (str)
  (let* ((n (char-index #\. (dropstring str 1))))
    (if (null n)
        (error* "lack of filename ext" str))
    (substring str 0 n)))

(defun dropstring (str n)
  (substring str n (- (length str) 1)))

(defun substring (str m n)
  (for ((i m (+ i 1))
        (str1 ""))
       ((> i n) str1)
       (setq str1 (string-append str1 (convert (elt str i) <string>)))))

;; to test pp1 in standard-input
(defun pp ()
    (pp1 (sexp-read) 0))

;; pretty-print if omitted ignore, pp1 doesn't care syntax
(defun pp1 (x lm :rest ignore)
    (cond ((consp x)
           (cond ((vector-p x) (pp-vector x lm))
                 ((array-p x) (pp-array x lm))
                 ((or (quote-p x)(backquote-p x)) (pp-quote x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "cond")) (pp-cond x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "case")) (pp-case x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "if")) (pp-if x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "let")) (pp-let x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "let*")) (pp-let x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "for")) (pp-for x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "defun")) (pp-defun x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "defgeneric")) (pp-defun x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "defmacro")) (pp-defun x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "catch")) (pp-catch x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "block")) (pp-catch x lm))
                 ((and (null ignore) (stringp (car x)) (string= (car x) "while")) (pp-catch x lm))
                 ((long-element-p x) (pp-long-element x lm ignore))
                 ((< (+ (flatsize x) lm) width) (pp-flat x lm ignore))
                 (t (pp-indent x lm ignore))))
          ((null x) (pp-string "()"))
          ((characterp x) nil)
          ((string= x "") (format output-stream "~%"))
          ((short-comment-p x) (pp-string x)(newline lm))
          ((long-comment-p x) (pp-string x)(newline 0))
          (t (pp-string x))))


;; write symbol number string object
(defun pp-string (x)
    (format output-stream x))

;; syntax cond
(defun pp-cond (x lm)
    (pp-string "(cond ")
    (pp-cond1 (cdr x) (+ lm 6))
    (if (cond-has-otomo-p (cdr x) (+ lm 6))
        (pp-string ")")
        (pp-string " )")))

(defun pp-cond1 (x lm)
  (for ((s x (cdr s)))
       ((null s) t)
       (if (stringp (car s))
           (pp-string (car s))
           (pp1 (car s) lm))
       (if (and (not (null (cdr s)))
                (not (short-comment-p (car (cdr s)))))
           (newline lm))))

(defun cond-has-otomo-p (ls lm)
  (cond ((null ls) nil)
        ((cond-has-otomo-p1 (car ls) lm) t)
        (t (cond-has-otomo-p (cdr ls) lm))))

(defun cond-has-otomo-p1 (ls lm)
  (cond ((null ls) nil)
        ((stringp ls) nil)
        ((has-otomo-p (car ls) lm) t)
        (t (cond-has-otomo-p1 (cdr ls) lm))))



;; syntax case
(defun pp-case (x lm)
  (let ((lm1 (+ lm 3)))
    (pp-string "(case ")
    (pp1 (elt x 1) lm)
    (newline lm1)
    (pp-cond1 (cdr (cdr x)) lm1)
    (pp-string " )")))

;;syntax if
;;2 pattern (if test then) or (if test then else)
(defun pp-if (x lm)
  (let ((lm1 (+ lm 4)))
    (cond ((= (length x) 4)
           (pp-string "(if ")
           (pp1 (elt x 1) lm1)
           (newline lm1)
           (pp1 (elt x 2) lm1)
           (newline lm1)
           (pp1 (elt x 3) lm1)
           (pp-string " )"))
          (t (pp-string "(if ")
           (pp1 (elt x 1) lm1)
           (newline lm1)
           (pp1 (elt x 2) lm1)
           (pp-string " )")))))

;;syntax defun type
;;also defmacro defgeneric
(defun pp-defun (x lm)
  (let ((lm1 (+ lm 4)))
    (pp-string "(")
    (pp1 (elt x 0) lm1)
    (pp-string " ")
    (pp1 (elt x 1) lm1)
    (pp-string " ")
    (pp1 (elt x 2) lm1)
    (newline lm1)
    (pp-body (cdr (cdr (cdr x))) lm1)
    (pp-string ")" )
    (newline lm)))

;; syntax defun body
;; also body of let,let*,for
(defun pp-body (x lm)
  (for ((s x (cdr s)))
       ((null s) t) 
       (if (stringp (car s))
           (pp-string (car s))
           (pp1 (car s) lm))
      (if (and (not (null (cdr s)))  ;;not end element
               (not (and (the-p (car s)) (the-p (car (cdr s)))))  ;;not the declare
               (not (short-comment-p (car (cdr s))))) ;not comment next element
           (newline lm))))

;; syntax let
(defun pp-let (x lm)
  (let ((lm1 (+ lm 5))
        (lm2 (+ lm 3)))
    (pp-string "(")
    (pp1 (elt x 0) lm1)
    (pp-string " ")
    (pp-let1 (elt x 1) lm1)
    (newline lm2)
    (pp-body (cdr (cdr x)) lm2)
    (pp-string " )" )))
  
(defun pp-let1 (x lm)
  (pp-string "(")
  (for ((s x (cdr s)))
       ((null s) 
        (if (= (length x) 1)
            (pp-string ")") 
            (pp-string " )"))) 
       (if (stringp (car s))
           (pp-string (car s))
           (pp1 (car s) lm))
       (if (not (null (cdr s)))
           (newline (+ lm 1)))))


(defun pp-for (x lm)
  (let ((lm1 (+ lm 5)))
    (pp-string "(for ")
    (pp-let1 (elt x 1) lm1)
    (newline lm1)
    (pp-let1 (elt x 2) lm1)
    (newline lm1)
    (pp-body (cdr (cdr (cdr x))) lm1)
    (pp-string ")")))

(defun pp-vector (x lm)
  (pp-string "#")
  (pp-flat (cdr x) -1)) ;;to avoid newline

(defun pp-array (x lm)
  (pp-string (elt x 0))
  (pp1 (cdr x) -1)) ;;to avoid newline

(defun pp-quote (x lm)
  (pp1 (car x) lm)
  (pp1 (cdr x) (+ lm 1) t))

;; syntax catch type
(defun pp-catch (x lm)
  (let ((lm1 (+ lm 3)))
    (pp-string "(")
    (pp1 (elt x 0) lm1)
    (pp-string " ")
    (pp1 (elt x 1) lm1)
    (newline lm1)
    (pp-body (cdr (cdr x)) lm1)
    (pp-string ")")))


;; write cons as flat
(defun pp-flat (x lm :rest ignore)
  (pp-string "(")
  (for ((s x (cdr s))
        (lm1 (+ lm 1) (+ 1 lm1 (flatsize (car s)))))
       ((null s) 
        (pp-string ")")
        (if (= lm 0) (newline lm)))
       (if (stringp (car s))
           (pp-string (car s))
           (pp1 (car s) lm1 ignore)) 
       (if (not (null (cdr s)))
           (pp-string " "))))

;; write subr with long element
(defun pp-long-element (x lm :rest ignore)
  (let ((lm1 (+ 2 lm (length (car x)))))
    (pp-string "(")
    (pp-string (car x))
    (pp-string " ")
    (for ((s (cdr x) (cdr s)))
         ((null s) 
          (if (= (length x) 0)
              (pp-string ")")
              (pp-string " )")))
         (if (stringp (car s))
              (pp-string (car s))
              (pp1 (car s) lm1 ignore))
         (if (not (null (cdr s)))
              (newline lm1)))))

;; write cons with indent
(defun pp-indent (x lm :rest ignore)
  (pp-string "(")
  (for ((s x (cdr s)))
       ((null s) 
        (if (= (length x) 0)
            (pp-string ")")
            (pp-string " )"))) 
       (if (stringp (car s))
           (pp-string (car s))
           (pp1 (car s) (+ lm 1) ignore))
       (if (not (null (cdr s)))
           (newline (+ lm 3)))))



;; print n of spaces
(defun space (n)
    (for ((m n (- m 1)))
         ((<= m 0) t)
         (format output-stream " ")))

;; print linefeed and print spaces
(defun newline (lm)
    (format output-stream "~%")
    (space lm))
    

;; calculate size of character 
(defun flatsize (x)
  (cond ((null x) 1)
        ((characterp x) 0)
        ((stringp x) (length x))
        ((and (consp x) (stringp (car x)))
         (+ (length (car x)) 1 (flatsize (cdr x))))
        ((consp x) (+ (flatsize (car x)) 1 (flatsize (cdr x))))))


;; read S-expression. each atom is represented as string
(defun sexp-read ()
  (let ((token (get-token)))
    (cond ((and (characterp token)(char= token #\())
           (sexp-read-list))
          (t token))))


(defun sexp-read-list ()
  (let ((token nil)
        (result nil))
    (setq token (get-token))
    (cond ((and (characterp token)(char= token #\))) nil)
          ((and (characterp token)(char= token #\())
           (cons (sexp-read-list)(sexp-read-list)))
          (t (cons token (sexp-read-list))))))

;;get token
;;if file-end return eof symbol
;;if delimiter return the character
;;if empty line return ""
;;if string return extended string. e.g."''~A''"
;;if quote return ("'" elt1 elt2 ...)
;;if backquote return ("`" elt1 elt2 ...)
;;if vector return ("#" elt1 elt2 ...)
;;if array return  ("#2a" (... )(...))
;;if hex oct binary number return e.g. "#Xface" "#O0707" "#B01010101"
;;if omitted function return e.g. "#'foo"
;;else (symbol number character) return string 
(defun get-token ()
  (block exit
    (let ((token nil)
          (char nil))
      (setq char (getc))
      (cond ((skip-p char)                                  ;;newline skip
             (space-skip)(setq char (getc))))
      (cond ((skip-p char)                                  ;;space skip
             (space-skip)(setq char (getc))))
      (cond ((end-of-file-p char) (return-from exit char))  ;;EOF
            ((char= char #\null) "")                        ;;empty line
            ((delimiter-p char) char)                       ;;delimiter
            ((char= char #\")                               ;;string e.g. ''asdf''
             (setq token (cons #\' (cons #\' token)))
             (setq char (getc))
             (while (not (char= char #\"))
                    (setq token (cons char token))
                    (cond ((char= char #\\)
                           (setq token (cons (getc) token))))
                    (setq char (getc)))
             (setq token (cons #\' (cons #\' token)))
             (convert-to-string (reverse token)))
            ((and (char= char #\#) (char= (look) #\\))       ;;character e.g. "#\\a" double \
             (setq token (cons (getc) (cons char nil)))      
             (setq token (cons #\\ token))
             (setq token (cons (getc) token))
             (setq char (getc))
             (while (not (delimiter-p char))             
                      (setq token (cons char token))
                      (setq char (getc)))
             (ungetc char)
             (convert-to-string (reverse token)))
            ((char= char #\')                               ;;quote
             (setq token (cons char nil))
             (cons (convert-to-string token) (sexp-read)))
            ((char= char #\`)                               ;;back quote
             (setq token (cons char nil))
             (cons (convert-to-string token) (sexp-read)))
            ((and (char= char #\#) (char= (look) #\|))       ;;long comment #|..|#
             (setq token (cons (getc) (cons char nil)))
             (setq token (cons (getc) token))
             (setq char (getc))
             (while (not (and (char= char #\|)(char= (look) #\#)))             
                      (setq token (cons char token))
                      (setq char (getc)))
             (setq token (cons char token))
             (setq token (cons (getc) token))
             (convert-to-string (reverse token)))
            ((and (char= char #\#)(char= (look) #\( ))      ;;vector
             (setq token (cons char nil))
             (cons (convert-to-string token) (sexp-read)))
            ((and (char= char #\#)(char= (look) #\'))       ;;e.g. #'foo
             (setq token (cons (getc) (cons char nil)))
             (setq char (getc))
             (while (not (delimiter-p char))                 
                      (setq token (cons char token))
                      (setq char (getc)))
             (ungetc char)
             (convert-to-string (reverse token)))
            ((char= char #\#)                               
             (while (not (delimiter-p char))                 
                      (setq token (cons char token))
                      (setq char (getc)))
             (ungetc char)
             (setq token (reverse token))
             (cond ((member (elt token 1) '(#\X #\B #\O))
                    (convert-to-string token))  ;;hex oct bin integer
                   ((char= (elt token 2) #\a) (cons (convert-to-string token) (sexp-read))) ;;array
                   (t (convert-to-string token)))) ;;other 
            ((char= char #\;)                               ;;comment
             (setq token (cons char token))
             (setq char (getc))
             (while (not (char= char #\newline))
                    (setq token (cons char token))
                    (setq char (getc)))
             (ungetc char)
             (convert-to-string (reverse token))) 
            (t (while (not (delimiter-p char))               ;;atom
                      (setq token (cons char token))
                      (setq char (getc)))
               (ungetc char)
               (convert-to-string (reverse token)))))))

;;when first element of buffer is space tab or newline, skip
(defun space-skip ()
  ;;space skip
  (while (and (not (null buffer))
              (or (char= (car buffer) #\space)
                  (char= (car buffer) #\tab)
                  (char= (car buffer) #\newline)))
    (setq buffer (cdr buffer))))

;; convert atom to string
(defun convert-to-string (ls)
  (if (null ls)
      ""
      (string-append (convert (car ls) <string>)
                     (convert-to-string (cdr ls)))))


;; get one character from stream
(defun getc ()
  (block exit
    (let ((input nil)
          (result nil))
      (while (null buffer)
             (setq input (read-line input-stream nil 'eof))
             (cond ((end-of-file-p input)
                    (return-from exit 'eof))
                   ((string= input "") 
                    (return-from exit #\null))
                   (t (setq buffer (append (convert input <list>) '(#\newline))))))
      
      (setq result (car buffer))
      (setq buffer (cdr buffer))
      result)))

;; unget character to buffer
(defun ungetc (x)
  (setq buffer (cons x buffer)))

;; loop buffer not get
(defun look ()
  (car buffer))

;; if eof T else NIL
(defun end-of-file-p (x)
  (eq x 'eof))

;; if delimiter T else NIL. delimiter is space newline ledt-paren right paren
(defun delimiter-p (c)
  (and (characterp c)
       (member c '(#\space #\newline #\( #\) ))))

;;is it skip able character?
(defun skip-p (c)
  (and (characterp c)
       (member c '(#\space #\newline))))

;; ;;type comment
(defun short-comment-p (x)
  (and (stringp x)
       (not (string= x ""))
       (char= (elt x 0) #\;))) 

;; #|    |# type comment
(defun long-comment-p (x)
  (and (stringp x)
       (char= (elt x 0) #\#)
       (char= (elt x 1) #\|)))

;; e.g. (the a <integer>) return T else NIL
(defun the-p (x)
  (and (consp x)
       (stringp (car x))
       (string= (car x) "the")))

;; is it vector object?
(defun vector-p (x)
  (and (consp x)
       (stringp (elt x 0))
      (string= "#" (elt x 0))))

;; is it array object?
(defun array-p (x)
  (and (consp x)
       (stringp (elt x 0))
       (> (length (elt x 0)) 1)
       (stringp (elt (elt x 0) 0))
       (char= (elt (elt x 0) 0) #\#)))

;; is it quote? e.g. 'foo
(defun quote-p (x)
  (and (consp x)
       (stringp (elt x 0))
       (string= (elt x 0) "'")))

;; is it backquote? e.g. `(if a b c)
(defun backquote-p (x)
  (and (consp x)
       (stringp (elt x 0))
       (string= (elt x 0) "`")))


;; is subr that has long size element? e.g. (+ (asdfghjklqwert x)(lkjdslkjsdflkj y))
(defun long-element-p (x)
  (and (consp x)
       (stringp (car x))
       (subrp (convert (car x) <symbol>))
       (> (length x) 2)
       (long-element-p1 (cdr x))))

(defun long-element-p1 (x)
  (cond ((null x) t)
        ((> (flatsize (car x)) long) (long-element-p1 (cdr x)))
        (t nil)))

;; is one-liner?
(defun one-liner-p (x lm)
  (< (+ (flatsize x) lm) width))

;; has otomo in elements?
(defun has-otomo-p (x lm)
  (cond ((null x) nil)
        ((stringp x) nil)
        ((long-element-p x) t)
        ((one-liner-p x lm) nil)
        (t (or (has-otomo-p (car x) lm)
               (has-otomo-p (cdr x) lm)))))
