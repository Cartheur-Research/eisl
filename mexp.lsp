;;M���ꂩ��S�\���ւ̕ϊ���


(defglobal buffer nil)
(defglobal input-stream (standard-input))

(set-property 500 'weight '+)
(set-property 500 'weight '-)
(set-property 400 'weight '*)
(set-property 400 'weight '/)
(set-property 300 'weight '^)
(set-property 'yfx 'type '+)
(set-property 'yfx 'type '-)
(set-property 'yfx 'type '*)
(set-property 'yfx 'type '/)
(set-property 'xfy 'type '^)
(set-property '+ 'sexp '+)
(set-property '- 'sexp '-)
(set-property '* 'sexp '*)
(set-property 'quotient 'sexp '/)
(set-property 'expt 'sexp '^)

(defun get-weight (x)
  (property 'weight x))

(defun get-type (x)
  (property 'type x))

(defun get-sexp (x)
  (property 'sexp x))

(defun mexp ()
  (initialize)
  (repl))

(defun repl ()
  (block repl
    (cond ((catch 'exit
             (for ((s (parse)(parse)))
                  ((equal s '(quit)) (return-from repl t))
                  (if (and (consp s)(eq (elt s 0) 'load))
                      (format (standard-output) "~A~%" (ignore-errors (load* (elt s 1))))
                      (format (standard-output) "~A~%" (ignore-errors (eval s))))
                  (prompt))) t)
          (t (prompt)(repl)))))

;;������
;;���b�Z�[�W��\�����A�v�����v�g��\������
(defun initialize ()
  (setq buffer nil)
  (format (standard-output) "Meta expression translater~%")
  (prompt))


;;�v�����v�g��\������
(defun prompt ()
  (format (standard-output) "M> "))

;;�G���[����
(defun error* (msg arg)
  (format (standard-output) msg)
  (format (standard-output) "~A" arg)
  (format (standard-output) "~%")
  (setq buffer nil)
  (if (not (eq input-stream (standard-input)))
      (close input-stream))
  (setq input-stream (standard-input))
  (throw 'exit nil))

;;�t�@�C������M�����ǂݎ��A�]������
(defun load* (file)
  (let ((exp nil))
    (setq input-stream (open-input-file file))
    (setq exp (parse))
    (while (not (and (stringp exp)(string= exp "the end")))
           (eval exp)
           (setq exp (parse)))
    (close input-stream)
    (setq input-stream (standard-input))
    t))

;;M������X�g���[�����ǂݍ����S���ɕϊ�����B
;;end-of-file�̂Ƃ��ɂ͕�����"the end"��Ԃ��B
(defun parse ()
  (let ((exp (mexp-read))
        (ope (get-token))
        (terminal nil))
    (cond ((and (stringp exp)(string= exp "the end")) exp) ;end of file
          ((and (symbolp ope) (eq ope '<=))
           (let ((result (list 'defun (car exp) (cdr exp) (mexp-read))))
             (setq terminal (get-token))
             (if (not (terminalp terminal))
                 (error* "Syntax error expected period " terminal))         
             result))
          ((terminalp ope)
           exp)
          (t (error* "Syntax error " ope)))))

;;M�����W�����͂���ǂݎ��S�\���ɂ��ĕԂ��B
;;�N�H�[�g�L����ǂݎ�����ꍇ�ɂ͒����S�\���Ƃ݂Ȃ��B
;;�X�g���[������end-of-file���󂯎�����Ƃ��ɂ͕�����"the end"��Ԃ��B
(defun mexp-read ()
  (let ((token (get-token))
        (result nil))
    (cond ((end-of-file-p token) token) ;end of file
          ((and (characterp token)(char= token #\[))
           (setq result (mexp-read-list))
           (if (eq (elt result 1) '->)
               (convert-to-cond result)
               result))
          ((and (symbolp token)(or (eq token 'lambda)
                                   (eq token '^)))
           (if (not (char= (get-token) #\[))
               (error* "Syntax error expected [" token))
           (if (not (char= (get-token) #\[))
               (error* "Syntax error expected ]" token))
           (setq result (list 'lambda (mexp-read-list) (mexp-read)))
           (if (not (char= (get-token) #\]))
               (error* "Syntax error expected ]" token))
           (cond ((char= (look) #\[)
                  (get-token)
                  (cons result (mexp-read-list)))))
          ((and (symbolp token)(char= (look) #\[))
           (get-token)
           (setq result (cons token (mexp-read-list)))
           (if (operator-char-p (look))
               (formula result (get-token))
               result))
          ((and (symbolp token)(operator-char-p (look)))
           (formula token (get-token)))
          ((symbolp token) token)
          ((and (numberp token)(operator-char-p (look)))
           (formula token (get-token))) 
          ((and (characterp token)(char= token #\())
           (setq result (list 'quote (sexp-read-list)))
           (if (and (not (char= (look) #\.))
                    (not (char= (look) #\;))
                    (not (char= (look) #\])))
               (error* "Syntax error expected ; or ] " result))
           result)
          ((and (characterp token)(char= token #\'))
           (list 'quote (sexp-read)))
          ((delimiterp token)
           (error* "M-exp illegal object " token))
          (t token))))


(defun formula (operand1 operator)
  (formula1 operand1 (formula-read) operator (get-weight operator) (get-type operator)))

(defun formula1 (operand1 operand2 operator weight type)
  (let ((token (formula-read))) 
    (cond ((end-of-file-p token) token)
          ((delimiterp token)
           (ungetc token)
           (list (get-sexp operator) operand1 operand2))
          ((and (operatorp token)(not (null operator))
                (> weight (get-weight token)))
           (formula1 operand1 (list (get-sexp token) operand2 (formula-read)) operator weight type))
          ((and (operatorp token)(not (null operator))
                (< weight (get-weight token)))
           (formula1 (list (get-sexp operator) operand1 operand2) (formula-read) token weight type))
          ((and (operatorp token)(not (null operator))
                (eq type 'yfx)(= (get-weight token) weight))
           (formula1 (list (get-sexp operator) operand1 operand2) (formula-read) token weight type))
          ((and (operatorp token)(not (null operator))
                (eq type 'xfy)(= (get-weight token) weight))
           (formula1 operand1 (formula1 operand2 (formula-read) token (get-weight token)(get-type token))
                     operator weight type))
          (t (error* "Syntax error illegal formula" token)))))


(defun formula-read ()
  (let ((token (get-token)))
    (cond ((end-of-file-p token) token)
          ((delimiterp token) token)
          ((operatorp token) token)
          ((numberp token) token)
          ((and (symbolp token)(not (null buffer))(char= (look) #\[))
           (getc)
           (cons token (mexp-read-list)))
          ((symbolp token) token)
          (t (error* "Syntax error illegal formula element" token)))))    

(defun convert-to-cond (ls)
  (cond ((atom ls) ls)
        ((and (consp ls)(< (length ls) 3)) ls)
        ((and (consp ls)(>= (length ls) 3)(not (eq (elt ls 1) '->))) ls)
        (t (cons 'cond (convert-to-cond1 ls)))))

(defun convert-to-cond1 (ls)
  (cond ((null ls) nil)
        ((< (length ls) 3) ls)
        (t (cons (list (elt ls 0)(convert-to-cond (elt ls 2)))
                 (convert-to-cond1 (cdr (cdr (cdr ls))))))))

;;cond�߂�\��->�L��������Ƃ��� [a -> b;c -> d] = (a -> b c -> d)�̂悤��
;;�ϊ�����B
(defun mexp-read-list ()
  (let ((token (get-token))
        (result nil))
    (cond ((and (characterp token)(char= token #\])) nil)
          ((and (characterp token)(char= token #\[))
           (cons (mexp-read-list)(mexp-read-list)))
          ((and (characterp token)(char= token #\;)) 
           (mexp-read-list))
          ((and (symbolp token)(eq token '->))
           (cons token (mexp-read-list)))
          ((and (symbolp token)(char= (look) #\[))
           (get-token)
           (cons (cons token (mexp-read-list))
                 (mexp-read-list)))
          ((and (characterp token)(char= token #\())
           (setq result (sexp-read-list))
           (if (and (not (char= (look) #\-)) ;; check for ->
                    (not (char= (look) #\;))
                    (not (char= (look) #\])))
               (error* "Syntax error expected ; or ] " result))
           (cons (list 'quote result) (mexp-read-list)))
          ((and (characterp token)(char= token #\'))
           (cons (list 'quote (sexp-read)) (mexp-read-list)))
          ((numberp token)
           (if (operator-char-p (look))
               (cons (formula token (get-token))(mexp-read-list))
               (cons token (mexp-read-list))))
          ((symbolp token)
           (if (and (operator-char-p (look))(not (char= (look1) #\>)))
               (cons (formula token (get-token))(mexp-read-list))
               (cons token (mexp-read-list))))
          ((stringp token)
           (if (and (not (char= (look) #\-)) ;; check for ->
                    (not (char= (look) #\;))
                    (not (char= (look) #\])))
               (error* "Syntax error expected ; or ] " token))
           (cons token (mexp-read-list)))
          (t (error* "M-exp illegal object" token)))))

;;; 

;;S�\����ǂݎ��
(defun sexp-read ()
  (let ((token (get-token)))
    (cond ((and (characterp token)(char= token #\())
           (sexp-read-list))
          (t token))))

;;S�\���̃��X�g��ǂݎ��
(defun sexp-read-list ()
  (let ((token nil)
        (result nil))
    (setq token (get-token))
    (cond ((and (characterp token)(char= token #\))) nil)
          ((and (characterp token)(char= token #\())
           (cons (sexp-read-list)(sexp-read-list)))
          ((char= (look) #\.)
           (get-token)
           (setq result (cons token (sexp-read)))
           (get-token)
           result)
          ((atom token)
           (cons token (sexp-read-list))))))

;;�g�[�N����ǂݎ��B
;;�@1.1�̂悤�Ƀs���I�h�̌オ��łȂ��ꍇ�ɂ͕��������_���ƍl����
;;  1e-1 �̂悤�Ȍ`���̕��������_����؂�o���B
;;[]()�̂悤�ȋ�؂�L���ɒB�����ꍇ�ɂ͂��̕������o�b�t�@�ɖ߂�
;;end-of-file�̏ꍇ�ɂ�"the end"��Ԃ��B
(defun get-token ()
  (block exit
    (let ((token nil)
          (char nil))
      (setq char (space-skip))
      (if (end-of-file-p char)
          (return-from exit char))
      (setq char (getc))
      (if (end-of-file-p char)
          (return-from exit char))
      (cond ((delimiterp char) char)
            ((operator-char-p char)
             (cond ((and (char= char #\-)(char= (look) #\>))
                    (getc)
                    '->)
                    (t (convert-to-atom (list char)))))
            ((char= char #\")
             (setq token (cons char token))
             (setq char (getc))
             (while (not (char= char #\"))
                    (setq token (cons char token))
                    (setq char (getc)))
             (setq token (cons char token))
             (convert-to-atom (reverse token)))
            (t (while (and (not (delimiterp char))
                           (not (operator-char-p char)))
                      (setq token (cons char token))
                      (setq char (getc)))
               (cond ((and (char= char #\.)(not (null buffer))(number-char-p (look)))
                      (setq token (cons char token))
                      (setq char (getc))
                      (while (and (not (delimiterp char))
                                  (not (operator-char-p char)))
                             (setq token (cons char token))
                             (setq char (getc))))
                     ((and (char= char #\+)(char= (car token) #\e))
                      (setq token (cons char token))
                      (setq char (getc))
                      (while (and (not (delimiterp char))
                                  (not (operator-char-p char)))
                             (setq token (cons char token))
                             (setq char (getc))))
                     ((and (char= char #\-)(char= (car token) #\e))
                      (setq token (cons char token))
                      (setq char (getc))
                      (while (and (not (delimiterp char))
                                  (not (operator-char-p char)))
                             (setq token (cons char token))
                             (setq char (getc)))))
               (ungetc char)
               (convert-to-atom (reverse token)))))))

;;�������X�g���e��̃A�g���ɕϊ�����
(defun convert-to-atom (ls)
  (cond ((string-list-p ls)
         (convert-to-string (cut-both-side ls)))
        ((integer-list-p ls)
         (convert-to-integer ls))
        ((float-list-p ls)
         (convert-to-float ls))
        (t (convert-to-symbol ls))))

;;���X�g�̗��[���J�b�g����B
(defun cut-both-side (ls)
  (reverse (cdr (reverse (cdr ls)))))

;;�������X�g���V���{���ɕϊ�����
(defun convert-to-symbol (ls)
  (convert (convert-to-string ls) <symbol>))

;;�������X�g�𕶎���ɕϊ�����B
;;�V���{���͑啶���ɕϊ������
(defun convert-to-string (ls)
  (if (null ls)
      ""
      (string-append (convert (uppercase (car ls)) <string>)
                     (convert-to-string (cdr ls)))))

;;�A���t�@�x�b�g��������啶���ɕϊ�����
;;�A���t�@�x�b�g�ȊO�͂��̂܂�
(defun uppercase (x)
  (cond ((char= x #\a) #\A)
        ((char= x #\b) #\B)
        ((char= x #\c) #\C)
        ((char= x #\d) #\D)
        ((char= x #\e) #\E)
        ((char= x #\f) #\F)
        ((char= x #\g) #\G)
        ((char= x #\h) #\H)
        ((char= x #\i) #\I)
        ((char= x #\j) #\J)
        ((char= x #\k) #\K)
        ((char= x #\l) #\L)
        ((char= x #\m) #\M)
        ((char= x #\n) #\N)
        ((char= x #\o) #\O)
        ((char= x #\p) #\P)
        ((char= x #\q) #\Q)
        ((char= x #\r) #\R)
        ((char= x #\s) #\S)
        ((char= x #\t) #\T)
        ((char= x #\u) #\U)
        ((char= x #\v) #\V)
        ((char= x #\w) #\W)
        ((char= x #\x) #\X)
        ((char= x #\y) #\Y)
        ((char= x #\z) #\Z)
        ((char= x #\_) #\-)
        (t x)))

;;�������X�g�𐮐��ɕϊ�����
(defun convert-to-integer (ls)
  (convert (convert-to-string ls) <integer>))

;;�������X�g�𕂓������_���ɕϊ�����
(defun convert-to-float (ls)
  (convert (convert-to-string ls) <float>))

;;�t�@�C���X�g���[���̏I���ł����t���A�����łȂ����nil��Ԃ�
(defun end-of-file-p (x)
  (if (and (stringp x)(string= x "the end"))
      t
      nil))

;;��������؂�L���ł����t���A�����łȂ����nil��Ԃ�
(defun delimiterp (c)
  (if (and (characterp c)
           (member c '(#\space #\[ #\] #\( #\) #\; #\, #\' #\.)))
      t
      nil))


;;M����̏I�[�L���ł���s���I�h�ł����t���A�����łȂ����nil��Ԃ�
(defun terminalp (c)
  (and (characterp c)(char= c #\.)))

;;���Z�q�̕����̂Ƃ���t���A�����łȂ����nil��Ԃ�
(defun operator-char-p (c)
  (if (and (characterp c)(member c '(#\+ #\- #\* #\/ #\^)))
      t
      nil))

;;���J�b�R�̂Ƃ���t���A�����łȂ����nil��Ԃ�
(defun left-paren-p (c)
  (if (and (characterp c)(char= #\())
       t
       nil))

;;�E�J�b�R�̂Ƃ���t���A�����łȂ����nil��Ԃ�
(defun right-paren-p (c)
  (if (and (characterp c)(char= #\)))
       t
       nil))

;;���Z�q�̃V���{���̂Ƃ���t���A�����łȂ����nil��Ԃ�
(defun operatorp (x)
  (if (member x '(+ - * / ^))
      t
      nil))

;;�X�y�[�X�������Ăу^�u������ǂݔ�΂��B
;;end-of-file�ɒB�����ꍇ�ɂ͕�����"the end"��Ԃ��B
(defun space-skip ()
  (block exit
    (let ((char nil))
      (setq char (getc))
      (if (and (stringp char)(string= char "the end"))
          (return-from exit char))
      (while (or (char= char #\space)
                 (char= char #\tab))
             (setq char (getc))
             (if (and (stringp char)(string= char "the end"))
                 (return-from exit char)))
      (ungetc char))))


;;�o�b�t�@����1���������o���B�o�b�t�@����Ȃ�΃X�g���[�����ǂݎ��
;; !�}�[�N���������ꍇ�ɂ̓o�b�t�@��p���A�V���ȕ�����ǂݎ��
;;end-of-file�̏ꍇ�ɂ�"the end"��Ԃ��B
(defun getc ()
  (block exit
    (let ((input nil)
          (result nil))
      (while (null buffer)
             (setq input (read-line input-stream nil "the end"))
             (if (end-of-file-p input)
                 (return-from exit "the end")
                 (setq buffer (convert input <list>))))
      (cond ((char= (car buffer) #\!)
             (setq input (read-line input-stream nil "the end"))
             (if (end-of-file-p input)
                 (return-from exit "the end")
                 (setq buffer (convert input <list>)))))
      (setq result (car buffer))
      (setq buffer (cdr buffer))
      result)))

;;1������߂��B
(defun ungetc (c)
  (setq buffer (cons c buffer)))

;;�o�b�t�@�̐擪�v�f��`������
;;�o�b�t�@����Ȃ�΃s���I�h������Ԃ�
(defun look ()
  (block exit
    (let ((max (length buffer)))
      (if (null buffer)
          (return-from exit #\.))
      (for ((pos 0 (+ pos 1)))
           ((>= pos max) nil)
           (if (not (char= (elt buffer pos) #\space))
               (return-from exit (elt buffer pos)))))))

;;look�̂����ЂƂ��ǂ�
(defun look1 ()
  (block exit
    (let ((max (length buffer)))
      (if (null buffer)
          (return-from exit #\.))
      (for ((pos 0 (+ pos 1)))
           ((>= pos max) nil)
           (if (not (char= (elt buffer pos) #\space))
               (return-from exit (elt buffer (+ pos 1))))))))

;;�������X�g���������\���Ȃ��t���A�����łȂ����nil��Ԃ�
(defun string-list-p (ls)
  (and (char= (car ls) #\")
       (char= (car (reverse ls)) #\")))

;;�������X�g��������\���Ă���Ȃ��t���A�����łȂ����nil��Ԃ�
(defun integer-list-p (ls)
  (cond ((char= (car ls) #\+)
         (integer-list-p1 (cdr ls)))
        ((char= (car ls) #\-)
         (integer-list-p1 (cdr ls)))
        (t (integer-list-p1 ls))))

;;�����͕K��1�����̐���������\������Ă��Ȃ���΂Ȃ�Ȃ�
(defun integer-list-p1 (ls)
  (cond ((null ls) nil)
        ((and (number-char-p (car ls))(null (cdr ls))) t)
        ((not (number-char-p (car ls))) nil)
        (t (integer-list-p1 (cdr ls)))))

;;�������X�g�����������_����\���Ă���Ȃ��t���A�����łȂ����nil��Ԃ�
(defun float-list-p (ls)
  (cond ((not (number-char-p (car ls))) nil)
        ((char= (car ls) #\+)
         (float-list-p1 (cdr ls)))
        ((char= (car ls) #\-)
         (float-list-p1 (cdr ls)))
        (t (float-list-p1 ls))))

;;���������_���� 123.4�A123e4�A123e+4�A123e-4�̂悤�Ȍ`���Ƃ���
(defun float-list-p1 (ls)
  (cond ((null ls) nil)
        ((char= (car ls) #\.)
         (integer-list-p (cdr ls)))
        ((char= (car ls) #\e)
         (integer-list-p (cdr ls)))
        ((not (number-char-p (car ls))) nil)
        (t (float-list-p1 (cdr ls)))))

(defun number-char-p (x)
  (and (char>= x #\0)
       (char<= x #\9)))

