;;FAST compiler
#|
(defun xxx (x1 x2 ...) (foo1 x)(foo2 x2) ...)
#include "fast.h"
code0 prototype
code1 int f_xxx(int arglist)
code2 int xxx(int x1, int x2 ...)
code3 void init_tfunctions(void){
(deftfunc)("XXX" ,(int)f_XXX);
}
code4 ex (defglobal abc 1)
void declare(){Fset_cdr(makesym("abc"),makeint(1));
               Fset_opt(makesym("abc"),GLOBAL)};
init_deftfunc{
deftfunc("XXX",f_xxx);
}
code5,6,7 for lambda-form ex(lambda (x) x)
f_gensym(int x){
int res;
res = x;
return(res);
}
type inference code
example (tarai x y z) x,y,z = <fixnum>
code0 prototype
int f_tarai(int x, int y, int z)
code1
int f_tarai(int x, int y, int z){
    return(F_makeint(tarai(F_getint(x),F_getint(y),F_getint(z))));
}
code2
int tarai(int x, int y, int z){
    if(x <= y)
        return(y);
    else
        return(tarai(tarai(x-1,y,z),
               tarai(y-1,z,x),
               tarai(z-1,x,y)));
}
example (tarai x y z) x,y,z = <float>
code0 prototype
int f_tarai(int x, int y, int z)
code1
int f_tarai(int x, int y, int z){
    return(makeflt(tarai(get_float(x),get_float(y),get_float(z))));
}
code2
double tarai(double x, double y, double z){
    if(x <= y)
        return(y);
    else
        return(tarai(tarai(x-1,y,z),
               tarai(y-1,z,x),
               tarai(z-1,x,y)));
}
|#
(defmodule compiler
    (defmacro when (test :rest body)
        `(if ,test (progn ,@body)) )
    
    (defmacro unless (test :rest body)
        `(if (not ,test) (progn ,@body)) )
    
    (defun any (f ls)
        (cond ((null ls) nil)
              ((funcall f (car ls)) t)
              (t (any f (cdr ls))) ))
    
    (defun every (f ls)
        (cond ((null ls) t)
              ((funcall f (car ls)) (every f (cdr ls)))
              (t nil)))
    
    (defun take (n ls)
        (if (= n 0)
            nil
            (cons (car ls) (take (- n 1) (cdr ls)))))
    
    (defun drop (n ls)
        (if (= n 0)
            ls
            (drop (- n 1) (cdr ls))))
    
    (defun last (ls)
        (car (reverse ls)))
    
    (defun second-last (ls)
        (elt (reverse ls) 1))
    
    (defun remove (x ls)
        (cond ((null ls) nil)
              ((eq x (car ls)) (remove x (cdr ls)))
              (t (cons (car ls) (remove x (cdr ls))))))
    
    (defun append! (x y)
        (while (not (null (cdr x)))
           (setq x (cdr x)))
        (set-cdr y x))
    
    (defun position (x ls)
        (cond ((eq x (car ls)) 0)
              (t (+ 1 (position x (cdr ls))))))
    
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
              (str1 "") )
             ((> i n)
              str1 )
             (setq str1 (string-append str1 (convert (elt str i) <string>)))))
    
    ;; e.g. (a b) -> (asubst bsubst) 
    (defun subst (vars)
        (if (null vars)
            '()
            (cons
             (convert (string-append (convert (conv-name (car vars)) <string>) "subst") <symbol>)
             (subst (cdr vars)))))
    
    
    (defun alpha-conv (x vars subst)
        (cond ((null x) nil)
              ((and (symbolp x) (member x vars))
               (nth subst (- (length vars) (length (member x vars)))))
              ((atom x) x)
              (t (cons (alpha-conv (car x) vars subst) (alpha-conv (cdr x) vars subst)))))
    
    
    (defun nth (x n)
        (if (= n 0)
            (car x)
            (nth (cdr x) (- n 1))))
    
    
    (defglobal comp-global-var
               '(instream
                 not-need-res
                 not-need-colon
                 global-variable
                 function-arg
                 generic-name-arg
                 catch-block-tag
                 unwind-thunk
                 file-name-and-ext
                 lambda-count
                 lambda-nest
                 c-lang-option
                 code0
                 code1
                 code2
                 code3
                 code4
                 code5
                 code6
                 code7))
    
    (defglobal instream nil)
    (defglobal not-need-res
               '(labels
                 flet
                 return-from
                 go
                 tagbody
                 while
                 call-next-method
                 the
                 c-lang
                 c-define
                 c-include
                 c-option))
    
    (defglobal not-need-colon '(c-lang c-define c-include c-option))
    (defglobal global-variable nil)
    (defglobal function-arg nil)
    (defglobal generic-name-arg nil)
    (defglobal catch-block-tag nil)
    (defglobal unwind-thunk nil)
    (defglobal file-name-and-ext nil)
    (defglobal lambda-count 0)
    (defglobal lambda-nest 0)
    (defglobal c-lang-option nil)
    (defglobal optimize-enable nil)
    (defglobal inference-name nil)
    (defglobal code0 nil)
    (defglobal code1 nil)
    (defglobal code2 nil)
    (defglobal code3 nil)
    (defglobal code4 nil)
    (defglobal code5 nil)
    (defglobal code6 nil)
    (defglobal code7 nil)
    (defun error* (str x)
        (format (standard-output) "compile error ~A ~A ~%" str x)
        (throw 'exit t))
    
    ;; This function generate C code and write to file *.c
    ;; Caution! for raspi "gcc -O3 -w -shared -fPIC -o ";
    (defpublic compile-file (x)
        (setq file-name-and-ext x)
        (setq type-function nil)
        (inference-file x)
        (catch
         'exit
         (unwind-protect
          (compile-file1 x)
          (if instream
              (close instream))
          (ignore-toplevel-check nil)))
        t)
    
    (defun compile-file1 (x)
        (let ((option
              (cond ((eq (self-introduction) 'windows) "gcc -O3 -shared -o ")
                    ((eq (self-introduction) 'linux) "gcc -O3 -w -shared -I$HOME/eisl -fPIC -o ")))
              (fname (filename x)) )
           (ignore-toplevel-check t)
           (format (standard-output) "initialize~%")
           (initialize)
           (format (standard-output) "pass1~%")
           (pass1 x)
           (format (standard-output) "pass2~%")
           (pass2 x)
           (ignore-toplevel-check nil)
           (format (standard-output) "finalize~%")
           (finalize x ".c")
           (format (standard-output) "invoke GCC~%")
           (system (string-append option fname ".o " fname ".c " c-lang-option))
           (system (string-append "rm " fname ".c"))))
    
    
    ;;for debug compile c-code only.
    (defun compile-file* (x)
        (let ((comp
              (cond ((eq (self-introduction) 'windows) "gcc -O3 -shared -o ")
                    ((eq (self-introduction) 'linux) "gcc -O3 -w -shared -I/home/eisl -fPIC -o ")))
              (fname (filename x)) )
           (format (standard-output) "invoke GCC~%")
           (system (string-append comp fname ".o " fname ".c"))))
    
    
    (defun compile-cuda (x)
        (setq file-name-and-ext x)
        (setq type-function nil)
        (inference-file x)
        (catch
         'exit
         (unwind-protect
          (compile-cuda1 x)
          (if instream
              (close instream))
          (ignore-toplevel-check nil)))
        t)
    
    (defun compile-cuda1 (x)
        (let ((option
              (cond ((eq (self-introduction) 'windows) "gcc -O3 -shared -o ")
                    ((eq (self-introduction) 'linux)
                     "nvcc -O3 -w -shared -I$HOME/eisl --compiler-options '-fPIC' -lcublas -o ")))
              (fname (filename x)) )
           (ignore-toplevel-check t)
           (format (standard-output) "initialize~%")
           (initialize)
           (format (standard-output) "pass1~%")
           (pass1 x)
           (format (standard-output) "pass2~%")
           (pass2 x)
           (ignore-toplevel-check nil)
           (format (standard-output) "finalize~%")
           (finalize x ".cu")
           (format (standard-output) "invoke NVCC~%")
           (system (string-append option fname ".o " fname ".cu " c-lang-option))
           (system (string-append "rm " fname ".cu"))))
    
    
    (defun pass1 (x)
        (setq instream (open-input-file x))
        (let ((sexp nil))
           (while (setq sexp (read instream nil nil))
              (cond ((and (consp sexp)(eq (car sexp) 'defmodule)) (module-check sexp))
                    (t (check-args-count sexp) (find-catch-block-tag sexp))))
           (close instream)
           (setq instream nil)))
    
    (defun module-check (x)
        (for ((name (car (cdr x)))
              (body (cdr (cdr x)) (cdr body)))
             ((null body) t)
             (let ((sexp (substitute (car body) name nil)))
                (check-args-count sexp)
                (find-catch-block-tag sexp))))

    (defun check-args-count (x)
        (cond ((eq (car x) 'defun)
               (when (assoc (elt x 1) function-arg) (error* "duplicate definition" (elt x 1)))
               (setq function-arg (cons (cons (elt x 1) (count-args (elt x 2))) function-arg)))
              ((eq (car x) 'defmacro)
               (unless (symbolp (elt x 1)) (error* "defmacro: not symbol" (elt x 1)))
               (unless (listp (elt x 2)) (error* "defmacro: not list" (elt x 2)))
               (when (null (cdr (cdr (cdr x)))) (error* "defmacro: not exist body" x))
               (when (assoc (elt x 1) function-arg) (error* "duplicate definition" (elt x 1)))
               (setq function-arg (cons (cons (elt x 1) (count-args (elt x 2))) function-arg))
               (eval x))
              ((eq (car x) 'defglobal)
               (unless (= (length x) 3) (error* "defglobal: illegal form" x))
               (unless (symbolp (elt x 1)) (error: "defglobal: not symbol" (elt x 1)))
               (setq global-variable (cons (elt x 1) global-variable))
               (if (and (not (member (elt x 1) comp-global-var)) (atom (elt x 2)))
                   (eval x)))
              ((eq (car x) 'defconstant)
               (unless (= (length x) 3) (error* "defconstant: illegal form" x))
               (unless (symbolp (elt x 1)) (error: "defconstant: not symbol" (elt x 1)))
               (setq global-variable (cons (elt x 1) global-variable))
               (if (and (not (member (elt x 1) comp-global-var)) (atom (elt x 2)))
                   (eval x)))
              ((eq (car x) 'defclass)
               (unless (symbolp (elt x 1)) (error* "defclass: not symbol" (elt x 1)))
               (unless (listp (elt x 2)) (error* "defclass: not list" (elt x 2)))
               (eval x))
              ((eq (car x) 'defgeneric)
               (unless (symbolp (elt x 1)) (error* "defgeneric: not symbol " (elt x 1)))
               (unless (listp (elt x 2)) (error* "defgeneric: not list " (elt x 2)))
               (when (assoc (elt x 1) function-arg) (error* "duplicate definition" (elt x 1)))
               (setq function-arg (cons (cons (elt x 1) (count-args (elt x 2))) function-arg))
               (setq generic-name-arg (cons (cons (elt x 1) (elt x 2)) generic-name-arg))
               (eval x))
              ((eq (car x) 'defmethod)
               (unless (symbolp (elt x 1)) (error* "defmethod: not symbol" (elt x 1)))
               (unless
                (or (listp (elt x 2)) (symbolp (elt x 2)))
                (error* "defmethod: not list" (elt x 2)))
               (when
                (and (listp (elt x 2)) (null (cdr (cdr (cdr x)))))
                (error* "defmethod: not exist body" x))
               (when
                (and (symbolp (elt x 2)) (null (cdr (cdr (cdr (cdr x))))))
                (error* "defmethod: not exist body" x))
               (eval x))))
    
    (defun find-catch-block-tag (x)
        (cond ((null x) nil)
              ((atom x) nil)
              ((and
                (eq (car x) 'catch)
                (>= (length x) 3)
                (consp (elt x 1))
                (= (length (elt x 1)) 2))
               (if (not (member (elt (elt x 1) 1) catch-block-tag))
                   (setq catch-block-tag (cons (elt (elt x 1) 1) catch-block-tag))))
              ((and (eq (car x) 'block) (>= (length x) 3) (symbolp (elt x 1)))
               (if (not (member (elt x 1) catch-block-tag))
                   (setq catch-block-tag (cons (elt x 1) catch-block-tag)))
               (find-catch-block-tag (cdr (cdr x))))
              ((consp (car x)) (find-catch-block-tag (car x)) (find-catch-block-tag (cdr x)))
              (t (find-catch-block-tag (cdr x)))))
    
    
    (defun pass2 (x)
        (setq instream (open-input-file x))
        (declare-catch-block-buffer)
        (let ((sexp nil))
           (while (setq sexp (read instream nil nil))
              (if (optimize-p sexp)
                  (setq optimize-enable t)
                  (setq optimize-enable nil))
              (compile sexp))
           (close instream)
           (setq instream nil)))
    
    (defun count-args (ls)
        (cond ((null ls) 0)
              ((= (length ls) 1) 1)
              ((eq (second-last ls) ':rest) (* -1 (- (length ls) 1)))
              ((eq (second-last ls) '&rest) (* -1 (- (length ls) 1)))
              (t (length ls))))
    
    
    (defun compile (x)
        (cond ((eq (car x) 'defun) (comp-defun x))
              ((eq (car x) 'defglobal) (comp-defglobal x))
              ((eq (car x) 'defdynamic) (comp-defdynamic x))
              ((eq (car x) 'defconstant) (comp-defconstant x))
              ((eq (car x) 'defmacro) (comp-defmacro x))
              ((eq (car x) 'defclass) (comp-defclass x))
              ((eq (car x) 'defgeneric) (comp-defgeneric x))
              ((eq (car x) 'defmethod) (comp-defmethod x))
              ((eq (car x) 'defmodule) (comp-defmodule x))
              (t (comp code4 x nil nil nil nil t nil nil) (format code4 ";"))))
    
    (defun comp (stream x env args tail name global test clos)
        (cond ((and (fixnump x) (not global))
               (cond ((not optimize-enable)
                      (format stream "fast_immediate(")
                      (format-integer stream x 10)
                      (format stream ")"))
                     (t (format-integer stream x 10))))
              ((and (fixnump x) global)
               (format stream "Fmakeint(")
               (format-integer stream x 10)
               (format stream ")"))
              ((floatp x)
               (cond ((not optimize-enable)
                      (format stream "Fmakestrflt(\"")
                      (format-float stream x)
                      (format stream "\")"))
                     (t (format-float stream x))))
              ((or (bignump x) (longnump x))
               (format stream "Fmakebig(\"")
               (format-integer stream x 10)
               (format stream "\")"))
              ((stringp x)
               (format stream "Fmakestr(")
               (format-char stream (convert 39 <character>))                               ;'
               (format-char stream (convert 39 <character>))                               ;'
               (format-object stream x nil)
               (format-char stream (convert 39 <character>))                               ;'
               (format-char stream (convert 39 <character>))                               ;'
               (format stream ")"))
              ((characterp x)
               (cond ((or
                       (char= x #\\)
                       (char= x (convert 34 <character>))                                  ;"
                       (char= x (convert 39 <character>)));'
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream #\\)
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format stream ")"))
                     ((special-char-p x)
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (print-special-char x stream)
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format stream ")"))
                     (t
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format stream ")"))))
              ((general-vector-p x)
               (format stream "Fvector(")
               (list-to-c1 stream (convert x <list>))
               (format stream ")"))
              ((general-array*-p x)
               (format stream "Farray(")
               (format-integer stream (length (array-dimensions x)) 10)
               (format stream ",")
               (list-to-c1 stream (readed-array-list x))
               (format stream ")"))
              ((and (symbolp x) clos)
               ;;in lambda
               (cond ((eq x nil) (format stream "NIL"))
                     ((eq x t) (format stream "T"))
                     ((member x clos)
                      (format stream "Fnth(")
                      (format-integer stream (position x clos) 10)
                      (format stream ",Fcdr(Fmakesym(\"")
                      (format stream (convert (conv-name name) <string>))
                      (format stream "\")))"))
                     ((member x env) (format stream (convert x <string>)))
                     (t
                      (format stream "fast_convert(Fcdr(Fmakesym(\"")
                      (format stream (convert x <string>))
                      (format stream "\")))"))))
              ((and (symbolp x) (not clos))
               ;;not in lambda
               (cond ((eq x nil) (format stream "NIL"))
                     ((eq x t) (format stream "T"))
                     ((member x env) (format stream (convert (conv-name x) <string>)))
                     (t
                      (when
                       (and
                        (not (member x global-variable))
                        (not (eq x '*pi*))
                        (not (eq x '*most-negative-float*))
                        (not (eq x '*most-positive-float*)))
                       (error* "undefined global variable" x))
                      (format stream "fast_convert(Fcdr(Fmakesym(\"")
                      (format stream (convert x <string>))
                      (format stream "\")))"))))
              ((and (consp x) (eq (car x) 'lambda)) (comp-lambda x env global))
              ((and (consp x) (macrop (car x)))
               (comp stream (macroexpand-1 x) env args tail name global test clos))
              ((and (consp x) (eq (car x) 'quote))
               (cond ((symbolp (elt x 1))
                      (format stream "Fmakesym(\"")
                      (format stream (convert (elt x 1) <string>))
                      (format stream "\")"))
                     ((consp (elt x 1)) (list-to-c1 stream (elt x 1)))
                     (t (comp stream (elt x 1) env args tail name global test clos))))
              ((and (consp x) (eq (car x) 'quasi-quote))
               (comp stream (quasi-transfer (elt x 1) 0) env args tail name global test clos))
              ((and (consp x) (eq (car x) 'if))
               (comp-if stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'cond))
               (comp-cond stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'case))
               (comp-case stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'case-using))
               (comp-case-using stream x env args tail name global test clos))
              ((and (consp x) (or (eq (car x) 'labels) (eq (car x) 'flet)))
               (comp-labels stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'let))
               (comp-let stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'let*))
               (comp-let* stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'and))
               (if test
                   (comp-test-and stream x env args tail name global test clos)
                   (comp-and stream x env args tail name global test clos)))
              ((and (consp x) (eq (car x) 'or))
               (if test
                   (comp-test-or stream x env args tail name global test clos)
                   (comp-or stream x env args tail name global test clos)))
              ((and (consp x) (eq (car x) 'progn))
               (comp-progn stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'for))
               (comp-for stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'while))
               (comp-while stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'setq))
               (comp-setq stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'tagbody))
               (comp-tagbody stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'go))
               (comp-go stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'block))
               (comp-block stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'return-from))
               (comp-return-from stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'convert))
               (comp-convert stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'function))
               (comp-function stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'symbol-function))
               (comp-symbol-function stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'class))
               (comp-class stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'symbol-class))
               (comp-symbol-class stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'catch))
               (comp-catch stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'throw))
               (comp-throw stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'unwind-protect))
               (comp-unwind-protect stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'setf))
               (comp-setf stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'dynamic))
               (comp-dynamic stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'set-dynamic))
               (comp-set-dynamic stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'dynamic-let))
               (comp-dynamic-let stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'call-next-method)) t)
              ;; ignore call-next-method
              ((and (consp x) (eq (car x) 'the)) t)
              ;; ignore call-next-method
              ((and (consp x) (eq (car x) 'not))
               (comp-not stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'car))
               (comp-car stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'cdr))
               (comp-cdr stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'cons))
               (comp-cons stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'length))
               (comp-length stream x env args tail name global test clos))
              ((and (consp x) (eq (car x) 'c-include)) (comp-c-include x))
              ((and (consp x) (eq (car x) 'c-define)) (comp-c-define x))
              ((and (consp x) (eq (car x) 'c-lang)) (comp-c-lang x))
              ((and (consp x) (eq (car x) 'c-option)) (comp-c-option x))
              ((and (consp x) (= (length x) 3) (member (car x) '(= < <= > >= + - * mod eq)))
               (comp-numeric stream x env args tail name global test clos))
              ((and (consp x) (subrp (car x)))
               (comp-subrcall stream x env args tail name global test clos))
              ((listp x) (comp-funcall stream x env args tail name global test clos))))
    
    (defun special-char-p (x)
        (member x '(#\alarm #\backspace #\delete #\escape #\return #\newline #\null #\space #\tab)))

    (defun print-special-char (x stream)
        (cond ((char= x #\alarm) (format stream "ALARM"))
              ((char= x #\backspace) (format stream "BACKSPACE"))
              ((char= x #\delete) (format stream "DELETE"))
              ((char= x #\escape) (format stream "ESCAPE"))
              ((char= x #\return) (format stream "RETURN"))
              ((char= x #\newline) (format stream "NEWLINE"))
              ((char= x #\null) (format stream "NULL"))
              ((char= x #\space) (format stream "SPACE"))
              ((char= x #\tab) (format stream "TAB"))))

    (defun initialize ()
        (setq global-variable nil)
        (setq function-arg nil)
        (setq generic-name-arg nil)
        (setq catch-block-tag nil)
        (setq c-lang-option "")
        (setq code0 (create-string-output-stream))
        (setq code1 (create-string-output-stream))
        (setq code2 (create-string-output-stream))
        (setq code3 (create-string-output-stream))
        (setq code4 (create-string-output-stream))
        (setq code5 (create-string-output-stream))
        (setq code6 (create-string-output-stream))
        (setq code7 (create-string-output-stream))
        (format code3 "void init_tfunctions(void){~%")
        (format code4 "void init_declare(void){~%"))
    
    (defun declare-catch-block-buffer ()
        (format code4 "Fsetcatchsymbols(")
        (list-to-c1 code4 catch-block-tag)
        (format code4 ");")
        (for ((tag catch-block-tag (cdr tag)))
             ((null tag)
              t )
             (format code0 "jmp_buf c_")
             (format-object code0 (conv-name (car tag)) nil)
             (format code0 "[50];~%")))
    
    (defun finalize (x ext)
        (format code3 "}")
        (format code4 "}")
        (let ((outstream (open-output-file (string-append (filename x) ext))))
           (format outstream "#include \"fast.h\"~%")
           (format outstream (get-output-stream-string code0))
           (format outstream (get-output-stream-string code1))
           (format outstream (get-output-stream-string code5))
           (format outstream (get-output-stream-string code6))
           (format outstream (get-output-stream-string code7))
           (format outstream (get-output-stream-string code2))
           (format outstream (get-output-stream-string code3))
           (format outstream (get-output-stream-string code4))
           (close outstream)))
    
    (defun comp-defun (x)
        (format (standard-output) "compiling ~A ~%" (elt x 1))
        (unless (symbolp (elt x 1)) (error* "defun: not symbol " (elt x 1)))
        (unless (listp (elt x 2)) (error* "defun: not list " (elt x 2)))
        (when (null (cdr (cdr (cdr x)))) (error* "defun: not exist body" (elt x 1)))
        (comp-defun0 x)
        (comp-defun1 x)
        (comp-defun2 x)
        (comp-defun3 x))
    
    ;;create lambda as SUBR and invoke the SUBR.
    (defun comp-lambda (x env global)
        (unless (listp (elt x 1)) (error* "lambda: not list" (elt x 1)))
        (when (null (cdr (cdr x))) (error* "lambda: not exist body" x))
        (setq lambda-nest (+ lambda-nest 1))
        (let* ((name (lambda-name))
               (args (elt x 1))
               (body (cdr (cdr x)))
               (free (find-free-variable body args env))
               (stream (lambda-stream-caller global)) )
            (comp-lambda0 x name)
            (comp-lambda1 x name)
            (comp-lambda2 body env args name free)
            (comp-lambda3 name)
            (format stream "({Fset_cdr(Fmakesym(\"")
            (format-object stream name nil)
            (format stream "\"),")
            (free-variable-list stream free)
            (format stream ");")
            (format stream "Fcar(Fmakesym(\"")
            (format-object stream name nil)
            (format stream "\"));})")
            (setq lambda-nest (- lambda-nest 1))))
    
    (defun lambda-name ()
        (let ((name
              (conv-name
               (convert
                (string-append (filename file-name-and-ext) (convert lambda-count <string>))
                <symbol>))))
           (setq lambda-count (+ lambda-count 1))
           name))
    
    (defun comp-defgeneric (x)
        (format (standard-output) "compiling ~A ~%" (elt x 1))
        (comp-defgeneric0 x)
        (comp-defgeneric1 x)
        (comp-defgeneric2 x)
        (comp-defgeneric3 x))
    
    (defun comp-defmodule (x)
        (let ((name (car (cdr x)))
              (body (cdr (cdr x))))
            (for ((s body (cdr s)))
                 ((null s) t)
                 (compile (substitute (car s) name nil)))))
    
    
    (defun comp-defun0 (x)
        (let* ((name (elt x 1))
               (args (elt x 2))
               (n (length args)) )
            (format code0 "int f_")
            (format-object code0 (conv-name name) nil)
            (format code0 "(int arglist);")
            (format code0 "int ")
            (format-object code0 (conv-name name) nil)
            (if (not optimize-enable)
                (gen-arg2 code0 args)
                (type-gen-arg2 code0 args (argument-type name)))
            (format code0 ";~%")))
    
    (defun comp-lambda0 (x name)
        (let* ((args (elt x 1))
               (n (length args)) )
            (format code0 "int f_")
            (format-object code0 (conv-name name) nil)
            (format code0 "(int arglist);")
            (format code0 "int ")
            (format-object code0 (conv-name name) nil)
            (gen-arg2 code0 args)
            (format code0 ";~%")))
    
    (defun comp-defgeneric0 (x)
        (let* ((name (elt x 1))
               (args (elt x 2))
               (n (length args)) )
            (format code0 "int f_")
            (format-object code0 (conv-name name) nil)
            (format code0 "(int arglist);")
            (format code0 "int ")
            (format-object code0 (conv-name name) nil)
            (gen-arg2 code0 args)
            (format code0 ";~%")))
    
    
    ;;generate f_XXX(int arg){...}
    (defun comp-defun1 (x)
        (let* ((name (elt x 1))
               (args (elt x 2))
               (n (count-args args)) )
            (format code1 "int f_")
            (format-object code1 (conv-name name) nil)
            (format code1 "(int arglist){~%")
            (gen-arg1 (abs n))
            (gen-assign n)
            (if (not optimize-enable)
                (gen-call (conv-name name) (abs n))
                (type-gen-call name (abs n)))
            (format code1 "}~%")))
    
    (defun comp-lambda1 (x name)
        (let* ((args (elt x 1))
               (n (count-args args)) )
            (format code1 "int f_")
            (format-object code1 (conv-name name) nil)
            (format code1 "(int arglist){~%")
            (gen-arg1 (abs n))
            (gen-assign n)
            (gen-call (conv-name name) (abs n))
            (format code1 "}~%")))
    
    (defun comp-defgeneric1 (x)
        (let* ((name (elt x 1))
               (args (elt x 2))
               (n (count-args args)) )
            (format code1 "int f_")
            (format-object code1 (conv-name name) nil)
            (format code1 "(int arglist){~%")
            (gen-arg1 (abs n))
            (gen-assign n)
            (gen-call (conv-name name) (abs n))
            (format code1 "}~%")))
    
    
    ;;genrate int XXX(int x, ...){...} this is main function.
    (defun comp-defun2 (x)
        (let ((name (elt x 1))
              (args (elt x 2))
              (body (cdr (cdr (cdr x)))) )
           (format code2 "int ")
           (format-object code2 (conv-name name) nil)
           (if (not optimize-enable)
               (gen-arg2 code2 args)
               (type-gen-arg2 code2 args (argument-type name)))
           (format code2 "{~%")
           (format code2 "int res;~%")
           ;;debug print ;(format code2 "printf("")
           ;(format-object code2 name nil)                                                ;(format code2 "   -->   ");")
           (cond ((and (not optimize-enable) (has-tail-recur-p body name))
                  ;;for tail recursive tempn var;
                  (gen-arg3 (length args)))
                 ((and optimize-enable (has-tail-recur-p body name))
                  (type-gen-arg3 (length args) (argument-type name))))
           (cond ((has-tail-recur-p body name)
                  (format-object code2 (conv-name name) nil)
                  (format code2 "loop:~%")))
           (cond ((not optimize-enable) (gen-shelterpush code2 args) (gen-checkgc)))
           (for ((body1 body (cdr body1)))
                ((null (cdr body1))
                 (if (and (not (not-need-res-p (car body1))) (not (tailcallp (car body1) t name)))
                    (format code2 "res = "))
                 (comp code2 (car body1) args args t name nil nil nil)
                 (if (not (not-need-colon-p (car body1)))
                    (format code2 ";~%"))
                 (if (not optimize-enable)
                    (gen-shelterpop code2 (reverse args)))
                 (format code2 "return(res);}~%") )
                (comp code2 (car body1) args args nil name nil nil nil)
                (if (not (not-need-colon-p (car body1)))
                    (format code2 ";~%")))))
    
    (defun comp-lambda2 (body env args name clos)
        (let ((stream (lambda-stream-callee)))
           (format stream "int ")
           (format-object stream (conv-name name) nil)
           (gen-arg2 stream args)
           (format stream "{~%")
           (format stream "int res;~%")
           (cond ((has-tail-recur-p body name)
                  (format-object stream (conv-name name) nil)
                  (format stream "loop:~%")))
           (gen-shelterpush stream args)
           (for ((body1 body (cdr body1)))
                ((null (cdr body1))
                 (if (not (not-need-res-p (car body1)))
                    (format stream "res = "))
                 (comp stream (car body1) args args nil name nil nil clos)
                 (format stream ";~%")
                 (gen-shelterpop stream (reverse args))
                 (format stream "return(res);}~%") )
                (comp stream (car body1) args args nil name nil nil clos)
                (format stream ";~%"))))
    
    ;;when lambda nest, select nested str-stream
    ;;for lambda callee
    (defun lambda-stream-callee ()
        (cond ((= lambda-nest 0) code5)
              ((= lambda-nest 1) code5)
              ((= lambda-nest 2) code6)
              ((= lambda-nest 3) code7)
              (t (error* "lambda: over nesting" lambda-nest))))
    
    (defun lambda-stream-caller (global)
        (cond (global code4)
              ((= lambda-nest 1) code2)
              ((= lambda-nest 2) code5)
              ((= lambda-nest 3) code6)
              (t (error* "lambda: over nesting" lambda-nest))))
    
    ;;for lambda find free-variable. if no variable return '(t)
    (defun find-free-variable (x env args)
        (append (find-free-variable1 x env args) '(t)))
    
    (defun find-free-variable1 (x env args)
        (cond ((null x) nil)
              ((and (symbolp x) (not (member x env)) (member x args)) (list x))
              ((atom x) nil)
              (t
               (append
                (find-free-variable1 (car x) env args)
                (find-free-variable1 (cdr x) env args)))))
    
    ;;create free-variable list to set lambda-name symbol
    (defun free-variable-list (stream x)
        (cond ((null x) (format stream "NIL"))
              (t
               (format stream "Fcons(")
               (format-object stream (conv-name (car x)) nil)
               (format stream ",")
               (free-variable-list stream (cdr x))
               (format stream ")"))))
    
    (defun comp-defgeneric2 (x)
        (let* ((name (elt x 1))
               (args (varlis-to-lambda-args (elt x 2)))
               (method (get-method name)) )
            (format code2 "int ")
            (format code2 (convert (conv-name name) <string>))
            (gen-arg2 code2 args)
            (format code2 "{~%")
            (format code2 "int res;~%")
            (gen-shelterpush code2 args)
            (gen-checkgc)
            (comp-defgeneric-body method nil)
            (gen-shelterpop code2 (reverse args))
            (format code2 "return(res);}~%")))
    
    ;;ex ((x <list>)y :rest z) -> (x y z)
    (defun varlis-to-lambda-args (x)
        (cond ((null x) nil)
              ((eq (car x) ':rest) (cdr x))
              ((eq (car x) ':rest) (cdr x))
              ((symbolp (car x)) (cons (car x) (varlis-to-lambda-args (cdr x))))
              ((consp (car x)) (cons (car (car x)) (varlis-to-lambda-args (cdr x))))
              (t (error* "defgeneric" x))))
    
    ;;method priority :around=11 :before=12 :priority=13 :after=14
    (defun comp-defgeneric-body (x after)
        (cond ((null x) t)
              ((null (cdr x))
               (let* ((varbody (get-method-body (car x)))
                      (varlis (car varbody))
                      (body (cdr varbody))
                      (priority (get-method-priority (car x))) )
                   (if (and (= priority 14) (not priority))
                       (format code2 "after:~%"))
                   (format code2 "if(")
                   (comp-defgeneric-cond varlis)
                   (format code2 ")~%{")
                   (comp-progn1 code2 body (varlis-to-lambda-args varlis) nil nil nil nil nil nil)
                   (if (and (method-need-return-p x) (not (equal (last body) '(call-next-method))))
                       (format code2 "return(res);"))
                   (format code2 "}~%")))
              (t
               (let* ((varbody (get-method-body (car x)))
                      (varlis (car varbody))
                      (body (cdr varbody))
                      (priority (get-method-priority (car x))) )
                   (if (and (= priority 14) (not after))
                       (format code2 "after:~%"))
                   (format code2 "if(")
                   (comp-defgeneric-cond varlis)
                   (format code2 ")~%{")
                   (comp-progn1 code2 body (varlis-to-lambda-args varlis) nil nil nil nil nil nil)
                   (if (and (method-need-return-p x) (not (equal (last body) '(call-next-method))))
                       (format code2 "return(res);"))
                   (if (and (= priority 13) (method-need-return-p1 (cdr x)))
                       (format code2 "goto after;"))
                   (format code2 "}~%")
                   (comp-defgeneric-body (cdr x) (if (= priority 14)
                                                     t
                                                     after))))))
    
    (defun method-need-return-p (x)
        (cond ((null (cdr x)) t)
              ((= (get-method-priority (car x)) 11) t)
              ((= (get-method-priority (car x)) 12) nil)
              ((and (= (get-method-priority (car x)) 13) (null (cdr x))) nil)
              ((and (= (get-method-priority (car x)) 13) (method-need-return-p1 (cdr x))) nil)
              ((and (= (get-method-priority (car x)) 14) (= (get-method-priority (elt x 1)) 14))
               nil)
              (t t)))
    
    (defun method-need-return-p1 (x)
        (cond ((null x) nil)
              ((= (get-method-priority (car x)) 11) nil)
              ((= (get-method-priority (car x)) 12) nil)
              ((= (get-method-priority (car x)) 14) t)
              (t (method-need-return-p1 (cdr x)))))
    
    ;;varlis -> C condition
    (defun comp-defgeneric-cond (x)
        (cond ((null x) t)
              ((eq (car x) ':rest) t)
              ((eq (car x) '%rest) t)
              ((symbolp (car x)) (comp-defgeneric-cond (cdr x)))
              ((consp (car x))
               (format code2 "Fadaptp(")
               (format-object code2 (conv-name (elt (car x) 0)) nil)
               (format code2 ",Fmakesym(\"")
               (format-object code2 (elt (car x) 1) nil)
               (format code2 "\"))")
               (comp-defgeneric-cond1 (cdr x)))
              (t (error* "defgeneric" x))))
    
    (defun comp-defgeneric-cond1 (x)
        (cond ((null x) t)
              ((eq (car x) ':rest) t)
              ((eq (car x) '%rest) t)
              ((symbolp (car x)) (comp-defgeneric-cond1 (cdr x)))
              ((consp (car x))
               (format code2 " && Fadaptp(")
               (format-object code2 (conv-name (elt (car x) 0)) nil)
               (format code2 ",Fmakesym(\"")
               (format-object code2 (elt (car x) 1) nil)
               (format code2 "\"))")
               (comp-defgeneric-cond1 (cdr x)))
              (t (error* "defgeneric" x))))
    
    
    ;;generate define code
    (defun comp-defun3 (x)
        (let ((name (elt x 1)))
           (format code3 "(deftfunc)(\"")
           (format-object code3 name nil)
           (format code3 "\" , f_")
           (format-object code3 (conv-name name) nil)
           (format code3 ");~%")))
    
    (defun comp-lambda3 (name)
        (format code3 "(deftfunc)(\"")
        (format-object code3 name nil)
        (format code3 "\" , f_")
        (format-object code3 (conv-name name) nil)
        (format code3 ");~%"))
    
    (defun comp-defgeneric3 (x)
        (let ((name (elt x 1)))
           (format code3 "(deftfunc)(\"")
           (format-object code3 name nil)
           (format code3 "\" , f_")
           (format-object code3 (conv-name name) nil)
           (format code3 ");~%")))
    
    ;; int arg1,arg2...argn;
    (defun gen-arg1 (n)
        (unless
         (= n 0)
         (format code1 "int ")
         (for ((m 1 (+ m 1)))
              ((= m n)
               (format code1 "arg")
               (format-object code1 m nil)
               (format code1 ";~%") )
              (format code1 "arg")
              (format-object code1 m nil)
              (format code1 ","))))
    
    ;; (x y z) -> (int x, int y, int z)
    ;; (x y :rest z) -> (int x, int y, int z)
    ;; output to stream of string
    (defun gen-arg2 (stream ls)
        (format stream "(")
        (if (null ls)
            (format stream ")")
            (for ((ls1 (remove '&rest (remove ':rest ls)) (cdr ls1)))
                 ((null (cdr ls1))
                  (format stream "int ")
                  (format-object stream (conv-name (car ls1)) nil)
                  (format stream ")") )
                 (format stream "int ")
                 (format-object stream (conv-name (car ls1)) nil)
                 (format stream ","))))
    
    ;; int temp1,temp2...tempn;
    (defun gen-arg3 (n)
        (unless
         (= n 0)
         (format code2 "int ")
         (for ((m 1 (+ m 1)))
              ((= m n)
               (format code2 "temp")
               (format code2 (convert m <string>))
               (format code2 ";~%") )
              (format code2 "temp")
              (format code2 (convert m <string>))
              (format code2 ","))))
    
    
    ;;arg1 = Fnth(1,arglist);
    ;;arg2 = Fnth(2,arglist);
    ;;when :rest parameter argn = Fnthcdr(n,arglist);
    (defun gen-assign (n)
        (cond ((= n 0) t)
              ((< n 0)
               (for ((m 1 (+ m 1)))
                    ((= m (abs n))
                     (format code1 "arg")
                     (format code1 (convert m <string>))
                     (format code1 " = Fnthcdr(")
                     (format code1 (convert (- m 1) <string>))
                     (format code1 ",arglist);~%") )
                    (format code1 "arg")
                    (format code1 (convert m <string>))
                    (format code1 " = Fnth(")
                    (format code1 (convert (- m 1) <string>))
                    (format code1 ",arglist);~%")))
              (t
               (for ((m 1 (+ m 1)))
                    ((> m n)
                     t )
                    (format code1 "arg")
                    (format code1 (convert m <string>))
                    (format code1 " = Fnth(")
                    (format code1 (convert (- m 1) <string>))
                    (format code1 ",arglist);~%")))))
    
    ;;(foo arg1 arg2) ->
    ;;  return(fast_inverse(foo(fast_convert(arg1),fast_convert(arg2))));
    (defun gen-call (name n)
        (cond ((= n 0)
               (format code1 "return(fast_inverse(")
               (format code1 (convert name <string>))
               (format code1 "() ));~%"))
              (t
               (format code1 "return(fast_inverse(")
               (format code1 (convert name <string>))
               (format code1 "(")
               (for ((m 1 (+ m 1)))
                    ((= m n)
                     (format code1 "fast_convert(arg")
                     (format code1 (convert m <string>))
                     (format code1 "))));~%") )
                    (format code1 "fast_convert(arg")
                    (format code1 (convert m <string>))
                    (format code1 "),")))))
    
    ;; args = (x)
    ;; if(CELLRANGE(x)) Fshelterpush(x)
    (defun gen-shelterpush (stream ls)
        (unless
         (null ls)
         (for ((ls1 (remove ':rest (remove '&rest ls)) (cdr ls1)))
              ((null ls1)
               t )
              (format stream "if(CELLRANGE(")
              (format-object stream (conv-name (car ls1)) nil)
              (format stream ")) Fshelterpush(")
              (format-object stream (conv-name (car ls1)) nil)
              (format stream ");~%"))))
    
    ;; args = (x)
    ;; if(CELLRANGE(x)) Fshelterpop(x)
    (defun gen-shelterpop (stream ls)
        (unless
         (null ls)
         (for ((ls1 (remove ':rest (remove '&rest ls)) (cdr ls1)))
              ((null ls1)
               t )
              (format stream "if(CELLRANGE(")
              (format-object stream (conv-name (car ls1)) nil)
              (format stream ")) ")
              (format-object stream (conv-name (car ls1)) nil)
              (format stream "=Fshelterpop();~%"))))
    
    ;;Fcheckgbc();
    (defun gen-checkgc ()
        (format code2 "Fcheckgbc();~%"))
    
    
    (defun comp-if (stream x env args tail name global test clos)
        (unless (or (= (length x) 3) (= (length x) 4)) (error* "if: illegal form" x))
        (cond ((= (length x) 3)
               (format stream "({int res;~%if(")
               (comp stream (elt x 1) env args tail name global t clos)
               (if (not optimize-enable)
                   (format stream " != NIL){~%")
                   (format stream "){~%"))
               (if (and
                    (not (not-need-res-p (elt x 2)))
                    ;;if cond etc ...
                    (not (tailcallp (elt x 2) tail name)))
                   ;;tail recur
                   (format stream "res = "))
               (comp stream (elt x 2) env args tail name global test clos)
               (format stream ";}~% else res = NIL;res;})~%"))
              ((= (length x) 4)
               (format stream "({int res;~%if(")
               (comp stream (elt x 1) env args tail name global t clos)
               (if (not optimize-enable)
                   (format stream " != NIL){~%")
                   (format stream "){~%"))
               (if (and
                    (not (not-need-res-p (elt x 2)))
                    ;;if cond etc ...
                    (not (tailcallp (elt x 2) tail name)))
                   ;;tail recur
                   (format stream "res = "))
               (comp stream (elt x 2) env args tail name global test clos)
               (format stream ";}~%")
               (format stream "else{~%")
               (if (and (not (not-need-res-p (elt x 3))) (not (tailcallp (elt x 3) tail name)))
                   (format stream "res = "))
               (comp stream (elt x 3) env args tail name global test clos)
               (format stream ";}res;})~%"))))
    
    ;;numeric function ex (= x y) etc...
    (defun comp-numeric (stream x env args tail name global test clos)
        (cond ((not optimize-enable)
               (format stream "({int res;Fargpush(fast_convert(")
               (comp stream (elt x 1) env args nil name global test clos)
               (format stream "));Fargpush(fast_convert(")
               (comp stream (elt x 2) env args nil name global test clos)
               (format stream "));")
               (cond ((eq (elt x 0) 'eq) (format stream "res=fast_eq();"))
                     ((eq (elt x 0) '=) (format stream "res=fast_numeqp();"))
                     ((eq (elt x 0) '<) (format stream "res=fast_smallerp();"))
                     ((eq (elt x 0) '<=) (format stream "res=fast_eqsmallerp();"))
                     ((eq (elt x 0) '>) (format stream "res=fast_greaterp();"))
                     ((eq (elt x 0) '>=) (format stream "res=fast_eqgreaterp();"))
                     ((eq (elt x 0) '+) (format stream "res=fast_plus();"))
                     ((eq (elt x 0) '-) (format stream "res=fast_minus();"))
                     ((eq (elt x 0) '*) (format stream "res=fast_mult();"))
                     ((eq (elt x 0) 'mod) (format stream "res=fast_mod();")))
               (format stream "res;})"))
              (t
               (comp stream (elt x 1) env args nil name global test clos)
               (cond ((eq (elt x 0) 'eq) (format stream "=="))
                     ((eq (elt x 0) '=) (format stream "=="))
                     ((eq (elt x 0) '<) (format stream "<"))
                     ((eq (elt x 0) '<=) (format stream "<="))
                     ((eq (elt x 0) '>) (format stream ">"))
                     ((eq (elt x 0) '>=) (format stream ">="))
                     ((eq (elt x 0) '+) (format stream "+"))
                     ((eq (elt x 0) '-) (format stream "-"))
                     ((eq (elt x 0) '*) (format stream "*"))
                     ((eq (elt x 0) 'mod) (format stream "%")))
               (comp stream (elt x 2) env args nil name global test clos))))
    
    
    
    ;; (foo x y z) -> foo(x,y,z)
    (defun comp-funcall (stream x env args tail name global test clos)
        (cond ((and tail (eq (car x) name))
               ;;tail call
               (comp-funcall1 stream x env args tail name global test clos))
              ((not (assoc (car x) function-arg))
               ;;interpreter
               (comp-funcall2 stream x env args tail name global test clos))
              ((null (cdr x))
               ;;thunk
               (unless
                (= (cdr (assoc (car x) function-arg)) 0)
                (error* "call: illegal argument count" x))
               (format-object stream (conv-name (car x)) nil)
               (format stream "()"))
              (t (comp-funcall-clang stream x env args tail name global test clos))))
    
    
    (defun comp-funcall-clang (stream x env args tail name global test clos)
        (let ((n (cdr (assoc (car x) function-arg))))
           (when (and (> n 0) (/= (length (cdr x)) n)) (error* "call: illegal arument count" x))
           (cond ((> n 0)
                  (format-object stream (conv-name (car x)) nil)
                  (format stream "(")
                  (for ((ls (cdr x) (cdr ls)))
                       ((null (cdr ls))
                        (comp stream (car ls) env args nil name global test clos)
                        (format stream ")") )
                       (comp stream (car ls) env args nil name global test clos)
                       (format stream ",")))
                 (t
                  (format-object stream (conv-name (car x)) nil)
                  (format stream "(")
                  (for ((ls (cdr x) (cdr ls))
                        (m (abs n) (- m 1)) )
                       ((= m 1)
                        (comp-funcall-clang1 stream ls env args nil name global test clos)
                        (format stream ")") )
                       (comp stream (car ls) env args nil name global test clos)
                       (format stream ","))))))
    
    (defun comp-funcall-clang1 (stream x env args tail name global test clos)
        (cond ((null x) (format stream "NIL"))
              (t
               (format stream "Fcons(fast_inverse(")
               (comp stream (car x) env args tail name global test clos)
               (format stream "),")
               (comp-funcall-clang1 stream (cdr x) env args tail name global test clos)
               (format stream ")"))))
    
    ;;tail recurcive function call
    (defun comp-funcall1 (stream x env args tail name global test clos)
        ;;{temp1=...; temp2=...; ... x=temp1;y=temp2; goto NAMEloop;}
        (format stream "{~%")
        (for ((ls (cdr x) (cdr ls))
              (n 1 (+ n 1)) )
             ((null ls)
              t )
             (format stream "temp")
             (format-integer stream n 10)
             (format stream " = ")
             (comp stream (car ls) env args nil name global test clos)
             (format stream ";~%"))
        (if (not optimize-enable)
            (gen-shelterpop stream args))
        (for ((ls args (cdr ls))
              (n 1 (+ n 1)) )
             ((null ls)
              t )
             (format-object stream (conv-name (car ls)) nil)
             (format stream " = temp")
             (format-integer stream n 10)
             (format stream ";~%"))
        (format stream "goto ")
        (format-object stream (conv-name name) nil)
        (format stream "loop;}"))
    
    ;;funcall for not SUBR function.
    ;;apply(func,args)
    (defun comp-funcall2 (stream x env args tail name global test clos)
        (format stream "Fapply(Fcar(Fmakesym(\"")
        (format-object stream (car x) nil)
        (format stream "\")),")
        (comp-subrcall2 stream (cdr x) env args nil name global test clos)
        (format stream ")"))
    
    ;;SUBR call
    ;;Not tail call subr.To avoid data loss by GC, push each data to shelter
    ;; ({int arg1,...,argn,res;
    ;;   arg1 = code1;
    ;;   Fshelterpush(arg1);
    ;;   ...
    ;;   argn = coden;
    ;;   Fshelterpush(argn);
    ;;   argn = Fshelterpop();
    ;;   ...
    ;;   arg1 = Fshelterpop();
    ;;   res = fcallsubr(_,arg1,...arg2);
    ;;   res;})
    ;; 
    (defun comp-subrcall (stream x env args tail name global test clos)
        (cond ((null (cdr x)) (format stream "({int res;"))
              (t
               (format stream "({int ")
               (for ((ls (cdr x) (cdr ls))
                     (n 1 (+ n 1)) )
                    ((null ls)
                     t )
                    (format stream "arg")
                    (format-integer stream n 10)
                    (format stream ","))
               (format stream "res;~%")
               (for ((ls (cdr x) (cdr ls))
                     (n 1 (+ n 1)) )
                    ((null ls)
                     t )
                    (format stream "arg")
                    (format-integer stream n 10)
                    (format stream " = fast_inverse(")
                    (comp stream (car ls) env args nil name global test clos)
                    (format stream ");~%")
                    (format stream "Fshelterpush(arg")
                    (format-integer stream n 10)
                    (format stream ");~%"))
               (for ((ls (cdr x) (cdr ls))
                     (n (length (cdr x)) (- n 1)) )
                    ((null ls)
                     t )
                    (format stream "arg")
                    (format-integer stream n 10)
                    (format stream "=Fshelterpop();~%"))))
        (format stream "res = fast_convert(Fcallsubr(Fcar(Fmakesym(\"")
        (format-object stream (car x) nil)
        (format stream "\")),")
        (comp-subrcall3 stream 1 (length (cdr x)))
        (format stream "));~%")
        (format stream ";res;})"))
    
    
    (defun comp-subrcall1 (stream x env args tail name global test clos)
        (cond ((null x) (format stream "NIL"))
              ((null (cdr x))
               (format stream "Flist1(fast_inverse(")
               (comp stream (car x) env args nil name global test clos)
               (format stream "))"))
              (t (comp-subrcall2 stream x env args tail name global test clos))))
    
    (defun comp-subrcall2 (stream x env args tail name global test clos)
        (cond ((null x) (format stream "NIL"))
              ((null (cdr x))
               (format stream "Flist1(fast_inverse(")
               (comp stream (car x) env args nil name global test clos)
               (format stream "))"))
              (t
               (format stream "Fcons(fast_inverse(")
               (comp stream (car x) env args nil name global test clos)
               (format stream "),")
               (comp-subrcall2 stream (cdr x) env args tail name global test clos)
               (format stream ")"))))
    
    
    (defun comp-subrcall3 (stream m n)
        (cond ((> m n) (format stream "NIL"))
              ((= m n)
               (format stream "Flist1(arg")
               (format-integer stream m 10)
               (format stream ")"))
              (t
               (format stream "Fcons(arg")
               (format-integer stream m 10)
               (format stream ",")
               (comp-subrcall3 stream (+ m 1) n)
               (format stream ")"))))
    
    ;;labels syntax. flet syntax is same as labels
    (defun comp-labels (stream x env args tail name global test clos)
        (comp-labels1 stream (elt x 1) env args tail name global test clos)
        (for ((body1 (cdr (cdr x)) (cdr body1)))
             ((null body1)
              (format stream "~%")
              (setq function-arg (drop (length (elt x 1)) function-arg)) )
             (if (not (not-need-res-p (car body1)))
                 (format stream "res = "))
             (comp stream (car body1) env args tail name global test clos)
             (format stream ";~%")))
    
    
    (defun comp-labels1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              (t
               (comp-labels2 stream (car x) env args tail name global test clos)
               (comp-labels1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-labels2 (stream x env args tail name global test clos)
        (when (< (length x) 3) (error* "labels: illegal form" x))
        (unless (symbolp (elt x 0)) (error* "labels: not symbol" (elt x 0)))
        (unless (listp (elt x 1)) (error* "labels: not list" (elt x 1)))
        (when (null (cdr (cdr x))) (error* "labels: not exist body" x))
        (let ((local-name (elt x 0))
              (args (elt x 1))
              (body (cdr (cdr x))) )
           (setq function-arg (cons (cons local-name (count-args args)) function-arg))
           (format code2 "int ")
           (format-object code2 (conv-name local-name) nil)
           (if (not optimize-enable)
               (gen-arg2 code2 args)
               (type-gen-arg2 code2 args (local-argument-type name local-name)))
           (format code2 "{~%")
           (format code2 "int res;~%")
           (cond ((and (not optimize-enable) (has-tail-recur-p body local-name))
                  ;;for tail recursive tempn var;
                  (gen-arg3 (length args)))
                 ((and optimize-enable (has-tail-recur-p body local-name))
                  (type-gen-arg3 (length args) (local-argument-type name local-name))))
           (cond ((has-tail-recur-p body local-name)
                  (format-object code2 (conv-name local-name) nil)
                  (format code2 "loop:~%")))
           (cond ((not optimize-enable) (gen-shelterpush code2 args) (gen-checkgc)))
           (for ((body1 body (cdr body1)))
                ((null body1)
                 (if (not optimize-enable)
                    (gen-shelterpop code2 (reverse args)))
                 (format code2 "return(res);}~%") )
                (if (not (not-need-res-p (car body1)))
                    (format code2 "res = "))
                (comp code2 (car body1) (append args env) args tail name global test clos)
                (format code2 ";~%"))))
    
    (defun comp-let (stream x env args tail name global test clos)
        (unless (listp (elt x 1)) (error* "let: not list" (elt x 1)))
        (format stream "({int res;")
        (comp-let1 stream (elt x 1) env args tail name global test clos)
        (for ((body1 (cdr (cdr x)) (cdr body1)))
             ((null (cdr body1))
              (if (not (tailcallp (car body1) tail name))
                 (format stream "res = "))
              (comp
              stream
              (car body1)
              (append (mapcar #'car (elt x 1)) env)
              args
              tail
              name
              global
              test
              clos)
              (if (not (not-need-colon-p (car body1)))
                 (format stream ";~%"))
              (format stream "res;})~%") )
             (comp
              stream
              (car body1)
              (append (mapcar #'car (elt x 1)) env)
              args
              tail
              name
              global
              test
              clos)
             (if (not (not-need-colon-p (car body1)))
                 (format stream ";~%"))))
    
    
    (defun comp-let* (stream x env args tail name global test clos)
        (unless (listp (elt x 1)) (error* "let*: not list" (elt x 1)))
        (format stream "({int res;")
        (comp-let1
         stream
         (elt x 1)
         (append (mapcar #'car (elt x 1)) env)
         args
         tail
         name
         global
         test
         clos)
        (for ((body1 (cdr (cdr x)) (cdr body1)))
             ((null (cdr body1))
              (if (not (tailcallp (car body1) tail name))
                 (format stream "res = "))
              (comp
              stream
              (car body1)
              (append (mapcar #'car (elt x 1)) env)
              args
              tail
              name
              global
              test
              clos)
              (if (not (not-need-colon-p (car body1)))
                 (format stream ";~%"))
              (format stream "res;})~%") )
             (comp
              stream
              (car body1)
              (append (mapcar #'car (elt x 1)) env)
              args
              tail
              name
              global
              test
              clos)
             (if (not (not-need-colon-p (car body1)))
                 (format stream ";~%"))))
    
    (defun not-need-res-p (x)
        (and (consp x) (member (car x) not-need-res)))
    
    (defun not-need-colon-p (x)
        (and (consp x) (member (car x) not-need-colon)))
    
    (defun tailcallp (x tail name)
        (and tail (and (consp x) (eq (car x) name))))
    
    (defun comp-let1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              (t
               (comp-let2 stream (car x) env args tail name global test clos)
               (comp-let1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-let2 (stream x env args tail name global test clos)
        (unless (symbolp (elt x 0)) (error* "let: illegal let form" x))
        (format stream "int ")
        (format stream (convert (conv-name (elt x 0)) <string>))
        (format stream " = fast_convert(")
        (comp stream (elt x 1) env args nil name global test clos)
        (format stream ");"))
    
    (defun comp-cond (stream x env args tail name global test clos)
        (format stream "({int res=NIL;~%if(")
        (comp stream (car (elt x 1)) env args tail name global t clos)
        (if (not optimize-enable)
            (format stream " != NIL){~%")
            (format stream "){~%"))
        (comp-cond2 stream (cdr (elt x 1)) env args tail name global test clos)
        (comp-cond1 stream (cdr (cdr x)) env args tail name global test clos))
    
    (defun comp-cond1 (stream x env args tail name global test clos)
        (cond ((null x) (format stream ";res;})"))
              ((eq (car (car x)) t)
               (format stream "else{~%")
               (comp-cond2 stream (cdr (car x)) env args tail name global test clos)
               (format stream ";res;})"))
              (t
               (format stream "else if(")
               (comp stream (car (car x)) env args nil name global t clos)
               (if (not optimize-enable)
                   (format stream " != NIL){~%")
                   (format stream "){~%"))
               (comp-cond2 stream (cdr (car x)) env args tail name global test clos)
               (comp-cond1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-cond2 (stream x env args tail name global test clos)
        (when (null x) (error* "cond: illegal form" x))
        (cond ((null (cdr x))
               (if (and (not (tailcallp (car x) t name)) (not (not-need-res-p (car x))))
                   (format stream "res = "))
               (comp stream (car x) env args t name global test clos)
               (if (not (not-need-colon-p (car x)))
                   (format stream ";"))
               (format stream "}~%"))
              (t
               (format stream "res = ")
               (comp stream (car x) env args nil name global test clos)
               (if (not (not-need-colon-p (car x)))
                   (format stream ";~%"))
               (comp-cond2 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-case (stream x env args tail name global test clos)
        (unless (consp (car (elt x 2))) (error* "case: illegal form" (car (elt x 2))))
        (format stream "({int res;~%if(Fmember(fast_inverse(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream "),")
        (list-to-c1 stream (car (elt x 2)))
        (format stream ") != NIL){~%")
        (comp-cond2 stream (cdr (elt x 2)) env args tail name global test clos)
        (comp-case1 stream (cdr (cdr (cdr x))) env args tail name global test clos (elt x 1)))
    
    (defun comp-case1 (stream x env args tail name global test clos key)
        (cond ((null x) (format stream ";res;})"))
              ((eq (car (car x)) t)
               (format stream "else{~%")
               (comp-cond2 stream (cdr (car x)) env args nil name global test clos)
               (format stream ";res;})"))
              (t
               (format stream "else if(Fmember(fast_inverse(")
               (comp stream key env args nil name global test clos)
               (format stream "),")
               (list-to-c1 stream (car (car x)))
               (format stream ") != NIL){~%")
               (comp-cond2 stream (cdr (car x)) env args nil name global test clos)
               (comp-case1 stream (cdr x) env args tail name global test clos key))))
    
    (defun comp-case-using (stream x env args tail name global test clos)
        (format stream "({int res;~%if(Fmember1(fast_inverse(")
        (comp stream (elt x 2) env args tail name global test clos)
        (format stream "),")
        (list-to-c1 stream (car (elt x 3)))
        (format stream ",")
        (comp stream (elt x 1) env args nil name global test clos)
        (format stream ") != NIL){~%")
        (comp-cond2 stream (cdr (elt x 3)) env args tail name global test clos)
        (comp-case-using1
         stream
         (cdr (cdr (cdr (cdr x))))
         env
         args
         tail
         name
         global
         test
         clos
         (elt x 2)
         (elt x 1)))
    
    (defun comp-case-using1 (stream x env args tail name global test clos key pred)
        (cond ((null x) (format stream ";res;})"))
              ((eq (car (car x)) t)
               (format stream "else{~%")
               (comp-cond2 stream (cdr (car x)) env args nil name global test clos)
               (format stream ";res;})"))
              (t
               (format stream "else if(Fmember1(fast_inverse(")
               (comp stream key env args nil name global test clos)
               (format stream "),")
               (list-to-c1 stream (car (car x)))
               (format stream ",")
               (comp stream pred env args nil name global test clos)
               (format stream ") != NIL){~%")
               (comp-cond2 stream (cdr (car x)) env args nil name global test clos)
               (comp-case-using1 stream (cdr x) env args tail name global test clos key pred))))
    
    
    (defun has-tail-recur-p (x name)
        (cond ((null x) nil)
              (t (has-tail-recur-p1 (last x) name))))
    
    (defun has-tail-recur-p1 (x name)
        (cond ((null x) nil)
              ((atom x) nil)
              ((not (consp x)) nil)
              ((eq (car x) name) t)
              ((eq (car x) 'cond) (any (lambda (y)
                                          (has-tail-recur-p (cdr y) name)) (cdr x)))
              ((eq (car x) 'if)
               (or
                (has-tail-recur-p1 (elt x 2) name)
                (and (= (length x) 4) (has-tail-recur-p1 (elt x 3) name))))
              ((eq (car x) 'let) (has-tail-recur-p (cdr (cdr x)) name))
              ((eq (car x) 'let*) (has-tail-recur-p (cdr (cdr x)) name))
              ((eq (car x) 'dynamic-let) (has-tail-recur-p (cdr (cdr x)) name))
              ((eq (car x) 'progn) (has-tail-recur-p (cdr x) name))
              ((eq (car x) 'block) (has-tail-recur-p (cdr (cdr x)) name))
              (t nil)))
    
    
    ;; comp-for alpha convert e.g.
    ;; from
    ;; (defun iota (n m)
    ;;  (for ((m m (- m 1))
    ;;        (a nil (cons m a)))
    ;;       ((< m n) a)))
    ;; to 
    ;; (defun iota (n m)
    ;;  (for ((msubst m (- msubst 1))
    ;;        (asubst nil (cons msubst asubst)))
    ;;       ((< msubst n) asubst)))
    (defun comp-for (stream x env args tail name global test clos)
        ;;alpha-convert variables.
        (let* ((vars1 (elt x 1))
               (var2 (mapcar #'car vars1))
               (var1 (subst var2))
               (vars (comp-for3 vars1 var2 var1))
               (end (alpha-conv (elt x 2) var2 var1))
               (body (alpha-conv (cdr (cdr (cdr x))) var2 var1)) )
            (when
             (any (lambda (x)
                     (eq (elt x 0) (elt x 1))) vars)
             (error* "for: illegal variable" vars))
            (when (any (lambda (x)
                          (not (symbolp x))) var1) (error* "for: illegal variable" vars))
            (format stream "({int res;~%")
            (comp-let1 stream vars env args nil name global test clos)
            (gen-arg3 (length vars))
            (format stream "while(")
            (comp stream (elt end 0) (append var1 env) args nil name global test clos)
            (format stream " == NIL){~%")
            (comp-for1 stream body (append var1 env) args nil name global test clos)
            (comp-for2 stream vars (append var1 env) args nil name global test clos)
            (if (not (null (cdr end)))
                (comp-progn1 stream (cdr end) (append var1 env) args tail name global test clos)
                (format stream "res=NIL;"))
            (format stream "res;})")))
    
    (defun comp-for1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              (t
               (comp stream (car x) env args tail name global test clos)
               (format stream ";~%")
               (comp-for1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-for2 (stream x env args tail name global test clos)
        (for ((update x (cdr update))
              (n 1 (+ n 1)) )
             ((null update)
              t )
             (when
              (= (length (car update)) 3)
              (format stream "temp")
              (format stream (convert n <string>))
              (format stream " = ")
              (comp stream (elt (car update) 2) env args tail name global test clos)
              (format stream ";~%")))
        (for ((update x (cdr update))
              (n 1 (+ n 1)) )
             ((null update)
              t )
             (when
              (= (length (car update)) 3)
              (format stream (convert (elt (car update) 0) <string>))
              (format stream " = temp")
              (format stream (convert n <string>))
              (format stream ";~%")))
        (format stream "}~%"))
    
    ;; alpha convert vars list
    (defun comp-for3 (vars var subst)
        (mapcar
         (lambda (x)
            (if (= (length x) 3)
                (list (alpha-conv (elt x 0) var subst) (elt x 1) (alpha-conv (elt x 2) var subst))
                (list (alpha-conv (elt x 0) var subst) (elt x 1))))
         vars))
    
    (defun comp-progn (stream x env args tail name global test clos)
        (format stream "({int res;~%")
        (comp-progn1 stream (cdr x) env args tail name global test clos)
        (format stream "res;})"))
    
    (defun comp-progn1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              ((null (cdr x))
               (if (and (not (not-need-res-p (car x))) (not (tailcallp (car x) tail name)))
                   (format stream "res = "))
               (comp stream (car x) env args tail name global test clos)
               (if (not (not-need-colon-p (car x)))
                   (format stream ";")))
              (t
               (comp stream (car x) env args nil name global test clos)
               (if (not (not-need-colon-p (car x)))
                   (format stream ";~%"))
               (comp-progn1 stream (cdr x) env args tail name global test clos))))
    
    
    (defun comp-and (stream x env args tail name global test clos)
        (format stream "({int res;~%if((res = ")
        (comp stream (elt x 1) env args nil name global test clos)
        (format stream ") != NIL)~%")
        (comp-and1 stream (cdr (cdr x)) env args nil name global test clos)
        (format stream "else res=NIL;res;})~%"))
    
    (defun comp-and1 (stream x env args tail name global test clos)
        (cond ((null x) (format stream "res=res;"))
              ((null (cdr x))
               (format stream "if((res=" env args tail name global)
               (comp stream (car x) env args nil name global test clos)
               (format stream ") !=NIL)~%res=res;~%else res=NIL;~%"))
              (t
               (format stream "if((res=")
               (comp stream (car x) env args nil name global test clos)
               (format stream ") != NIL)~%")
               (comp-and1 stream (cdr x) env args nil name global test clos)
               (format stream "else res=NIL;"))))
    
    (defun comp-or (stream x env args tail name global test clos)
        (format stream "({int res;~%if((res=")
        (comp stream (elt x 1) env args nil name global test clos)
        (format stream ") == NIL)~%")
        (comp-or1 stream (cdr (cdr x)) env args nil name global test clos)
        (format stream "else res=res;res;})~%"))
    
    (defun comp-or1 (stream x env args tail name global test clos)
        (cond ((null x) (format stream "res = res;"))
              ((null (cdr x))
               (format stream "if((res=" env args tail name global)
               (comp stream (car x) env args nil name global test clos)
               (format stream ") !=NIL)~%res=res;~%else res=NIL;~%"))
              (t
               (format stream "if((res=")
               (comp stream (car x) env args nil name global test clos)
               (format stream ") == NIL)~%")
               (comp-or1 stream (cdr x) env args nil name global test clos)
               (format stream "else res=res;"))))
    
    (defun comp-test-and (stream x env args tail name global test clos)
        (format stream "(")
        (comp-test-and1 stream (cdr x) env args tail name global test clos)
        (format stream ")"))
    
    (defun comp-test-and1 (stream x env args tail name global test clos)
        (cond ((null (cdr x)) (comp stream (car x) env args nil name global test clos))
              (t
               (comp stream (car x) env args nil name global test clos)
               (format stream " && ")
               (comp-test-and1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-test-or (stream x env args tail name global test clos)
        (format stream "(")
        (comp-test-or1 stream (cdr x) env args tail name global test clos)
        (format stream ")"))
    
    (defun comp-test-or1 (stream x env args tail name global test clos)
        (cond ((null (cdr x)) (comp stream (car x) env args nil name global test clos))
              (t
               (comp stream (car x) env args nil name global test clos)
               (format stream " || ")
               (comp-test-or1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-while (stream x env args tail name global test clos)
        (when (null (cdr (cdr x))) (error* "while: not exist body" x))
        (format stream "({int res;~%while(")
        (comp stream (elt x 1) env args tail name global t clos)
        (format stream " !=NIL){~%")
        (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
        (format stream "};res;})~%"))
    
    (defun comp-setq (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "setq: not symbol" x))
        (cond ((member (elt x 1) env)
               (format stream "({int res;~% res = ")
               (format-object stream (conv-name (elt x 1)) nil)
               (format stream " = ")
               (comp stream (elt x 2) env args tail name global test clos)
               (format stream ";res;})~%"))
              ((member (elt x 1) clos)
               (format stream "({int res;~% res = ")
               (format stream "fast_setnth(Fcdr(Fmakesym(\"")
               (format-object stream name nil)
               (format stream "\")),")
               (format-integer stream (position (elt x 1) clos) 10)
               (format stream ",")
               (comp stream (elt x 2) env args tail name global test clos)
               (format stream ");res;})"))
              (t
               (format stream "({int res;~% res = ")
               (format stream "Fset_cdr(Fmakesym(\"")
               (format stream (convert (elt x 1) <string>))
               (format stream "\"),fast_inverse(")
               (comp stream (elt x 2) env args nil name t test clos)
               (format stream "));res;})"))))
    
    (defun comp-tagbody (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "tagbody: not symbol" (elt x 1)))
        (format stream "({")
        (format stream (convert (conv-name (elt x 1)) <string>))
        (format stream ":~%")
        (comp-tagbody1 stream (cdr (cdr x)) env args tail name global test clos)
        (format stream "res;})~%"))
    
    (defun comp-tagbody1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              ((symbolp (car x))
               (format stream (convert (conv-name (car x)) <string>))
               (format stream ":~%")
               (comp-tagbody1 stream (cdr x) env args tail name global test clos))
              ((null (cdr x))
               (if (and (not (not-need-res-p (car x))) (not (tailcallp (car x) tail name)))
                   (format stream "res = "))
               (comp stream (car x) env args tail name global test clos)
               (format stream ";"))
              (t
               (comp stream (car x) env args nil name global test clos)
               (format stream ";~%")
               (comp-tagbody1 stream (cdr x) env args tail name global test clos))))
    
    
    (defun comp-go (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "go: not symbol" (elt x 1)))
        (format stream "goto ")
        (format stream (convert (conv-name (elt x 1)) <string>))
        (format stream ";~%"))
    
    
    (defun comp-convert (stream x env args tail name global test clos)
        (unless (symbolp (elt x 2)) (error* "convert: not symbol" x))
        (unless (= (length x) 3) (error* "convert: illegal form" x))
        (format stream "fast_convert(Fconvert(fast_inverse(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream "),Fmakesym(\"")
        (format-object stream (elt x 2) nil)
        (format stream "\")))"))
    
    (defun comp-function (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "function: illegal form" x))
        (unless (symbolp (elt x 1)) (error* "function: illegal form" x))
        (format stream "Fcar(Fmakesym(\"")
        (format-object stream (elt x 1) nil)
        (format stream "\"))"))
    
    (defun comp-symbol-function (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "symbol-function: illegal form" x))
        (unless (= (length x) 2) (error* "symbol-function: illegal form" x))
        (format stream "Fcar(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream ")"))
    
    (defun comp-class (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "class: illegal form" x))
        (unless (symbolp (elt x 1)) (error* "class: illegal form" x))
        (format stream "Faux(Fmakesym(\"")
        (format-object stream (elt x 1) nil)
        (format stream "\"))"))
    
    (defun comp-symbol-class (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "class: illegal form" x))
        (unless (symbolp (elt x 1)) (error* "class: illegal form" x))
        (format stream "Faux(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream ")"))
    
    (defun comp-catch (stream x env args tail name global test clos)
        (let ((tag (elt (elt x 1) 1)))
           (format stream "({int res,ret,i;~% ")
           (format stream "i = Fgetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"));~%")
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i+1);~%")
           (format stream "ret=setjmp(c_")
           (format-object stream (conv-name tag) nil)
           (format stream "[i]);")
           (format stream "if(ret == 0){~%")
           (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i);~%")
           (format stream "}~% else{~%")
           (format stream "ret = 0;~%")
           (cond (unwind-thunk (format-object stream unwind-thunk nil) (format stream "();")))
           (format stream "res=catch_arg;}~%")
           (format stream "res;})")))
    
    (defun comp-throw (stream x env args tail name global test clos)
        (let ((tag (elt (elt x 1) 1)))
           (format stream "({int res,i;~%")
           (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
           (format stream "catch_arg=res;~% ")
           (format stream "i = Fgetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"));~%")
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i-1);~%")
           (format stream "longjmp(c_")
           (format-object stream (conv-name tag) nil)
           (format stream "[i-1],1);res;})~%")))
    
    (defun comp-block (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "block: not symbol" (elt x 1)))
        (let ((tag (elt x 1)))
           (format stream "({int res,ret,i;~% ")
           (format stream "i = Fgetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"));~%")
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i+1);~%")
           (format stream "ret=setjmp(c_")
           (format-object stream (conv-name tag) nil)
           (format stream "[i]);")
           (format stream "if(ret == 0){~%")
           (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i);~%")
           (format stream "}~% else{~%")
           (format stream "ret = 0;~%")
           (cond (unwind-thunk (format-object stream unwind-thunk nil) (format stream "();")))
           (format stream "res=block_arg;}~%")
           (format stream "res;})")))
    
    
    (defun comp-return-from (stream x env args tail name global test clos)
        (unless (symbolp (elt x 1)) (error* "return-from: not symbol" (elt x 1)))
        (let ((tag (elt x 1)))
           (format stream "({int res,i;~%")
           (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
           (format stream "block_arg=res;~% ")
           (format stream "i = Fgetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"));~%")
           (format stream "Fsetprop(Fmakesym(\"")
           (format-object stream tag nil)
           (format stream "\"),i-1);~%")
           (format stream "longjmp(c_")
           (format-object stream (conv-name tag) nil)
           (format stream "[i-1],1);res;})~%")))
    
    (defun comp-unwind-protect (stream x env args tail name global test clos)
        (format stream "({int res;~%")
        (setq unwind-thunk (comp-unwind-protect1 (cdr (cdr x)) env))
        (format stream "res=")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream ";res;})"))
    
    ;;create lambda thuck for unwind. and return the lambda-name
    (defun comp-unwind-protect1 (body env)
        (let* ((x (append '(lambda ()) body))
               (name (lambda-name))
               (args '())
               (free (find-free-variable body args env)) )
            (comp-lambda0 x name)
            (comp-lambda1 x name)
            (comp-lambda2 body env args name free)
            (comp-lambda3 name)
            name))
    
    (defun comp-setf (stream x env args tail name global test clos)
        (unless (= (length x) 3) (error* "setf: illegal form" x))
        (when (or (eq (elt x 1) t) (eq (elt x 1) nil)) (error* "setf: can't modify" x))
        (let ((form (elt x 1))
              (val (elt x 2)) )
           (cond ((and (consp form) (eq (car form) 'aref))
                  (let ((newform (cons 'set-aref (cons val (cdr form)))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (eq (car form) 'garef))
                  (let ((newform (cons 'set-garef (cons val (cdr form)))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (eq (car form) 'elt))
                  (let ((newform (cons 'set-elt (cons val (cdr form)))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (eq (car form) 'property))
                  (let ((newform (cons 'set-property (cons val (cdr form)))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (= (length form) 2) (eq (car form) 'car))
                  (let ((newform (list 'set-car val (elt form 1))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (= (length form) 2) (eq (car form) 'cdr))
                  (let ((newform (list 'set-cdr val (elt form 1))))
                     (comp stream newform env args tail name global test clos)))
                 ((and (consp form) (eq (car form) 'dynamic))
                  (let ((newform (list 'set-dynamic (elt form 1) val)))
                     (comp stream newform env args tail name global test clos)))
                 ((and
                   (consp form)
                   (= (length form) 2)
                   (symbolp (elt form 0))
                   (symbolp (elt form 1)))
                  (let ((newform
                        (list
                         'set-slot-value
                         val
                         (elt form 1)
                         (list 'quote (eval (list (elt form 0) nil))))))
                     (comp stream newform env args tail name global test clos)))
                 ((symbolp form)
                  (comp-setq stream (list 'setq form val) env args tail name global test clos))
                 (t (error* "setf: illegal form" x)))))
    
    (defun comp-dynamic (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "dynamic: illegal form" x))
        (unless (symbolp (elt x 1)) (error* "dynamic: illegal form" x))
        (format stream "fast_convert(Ffinddyn(Fmakesym(\"")
        (format-object stream (elt x 1) nil)
        (format stream "\")))"))
    
    (defun comp-dynamic-let (stream x env args tail name global test clos)
        (format stream "({int res,val,save,dynpt;~% save=Fgetdynpt();~%")
        (comp-dynamic-let1 stream (elt x 1) env args tail name global test clos)
        (comp-progn1 stream (cdr (cdr x)) env args tail name global test clos)
        (format stream "res;})"))
    
    (defun comp-dynamic-let1 (stream x env args tail name global test clos)
        (cond ((null x) t)
              (t
               (comp-dynamic-let2 stream (car x) env args tail name global test clos)
               (comp-dynamic-let1 stream (cdr x) env args tail name global test clos))))
    
    (defun comp-dynamic-let2 (stream x env args tail name global test clos)
        (unless (symbolp (elt x 0)) (error* "dynamic-let: illegal let form" x))
        (let ((symbol (elt x 0))
              (value (elt x 1)) )
           (format stream "dynpt=Fgetdynpt();Fshelterpush(dynpt);Fsetdynpt(save);~%")
           (format stream "val=fast_inverse(")
           (comp stream value env args nil name global test clos)
           (format stream ");Fsetdynpt(dynpt);Fshelterpop();")
           (format stream "Fadddynenv(Fmakesym(\"")
           (format-object stream symbol nil)
           (format stream "\"),val);")))
    
    
    (defun comp-not (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "not: illegal form" x))
        (format stream "fast_not(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream ")"))
    
    (defun comp-car (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "car: illegal form" x))
        (unless (or (symbolp (elt x 1)) (consp (elt x 1))) (error* "car: illegal argument" x))
        (format stream "fast_convert(fast_car(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream "))"))
    
    (defun comp-cdr (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "cdr: illegal form" x))
        (unless (or (symbolp (elt x 1)) (consp (elt x 1))) (error* "cdr: illegal argument" x))
        (format stream "fast_convert(fast_cdr(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream "))"))
    
    (defun comp-cons (stream x env args tail name global test clos)
        (unless (= (length x) 3) (error* "cons: illegal form" x))
        (format stream "Fcons(fast_inverse(")
        (comp stream (elt x 1) env args nil name global test clos)
        (format stream "),fast_inverse(")
        (comp stream (elt x 2) env args nil name global test clos)
        (format stream "))"))
    
    (defun comp-length (stream x env args tail name global test clos)
        (unless (= (length x) 2) (error* "length: illegal form" x))
        (unless
         (or (symbolp (elt x 1)) (listp (elt x 1)) (general-vector-p (elt x 1)))
         (error* "length: illegal argument" x))
        (format stream "Flength(")
        (comp stream (elt x 1) env args tail name global test clos)
        (format stream ")"))
    
    ;;add code0 stream #include C code.
    (defun comp-c-include (x)
        (unless (= (length x) 2) (error* "c-include: illegal form" x))
        (unless (stringp (elt x 1)) (error* "c-include: argument must be string" x))
        (format code0 "#include ")
        (format code0 (elt x 1))
        (format code0 "~%"))
    
    ;;add code2 stream C define
    (defun comp-c-define (x)
        (unless (= (length x) 3) (error* "c-define: illegal form" x))
        (unless (stringp (elt x 1)) (error* "c-define: argument must be string" x))
        (format code0 "#define ")
        (format code0 (elt x 1))
        (format code0 " ")
        (format code0 (elt x 2))
        (format code0 "~%"))
    
    ;;add code2 stream C language code.
    (defun comp-c-lang (x)
        (unless (= (length x) 2) (error* "c-lang: illegal form" x))
        (unless (stringp (elt x 1)) (error* "c-lang: argument must be string" x))
        (format-object code2 (elt x 1) nil)
        (format code2 "~%"))
    
    ;;add compile option
    (defun comp-c-option (x)
        (setq c-lang-option (elt x 1)))
    
    
    ;;defglobal
    (defun comp-defglobal (x)
        (let ((symbol (elt x 1))
              (value (elt x 2)) )
           (format code4 "Fset_cdr(Fmakesym(\"")
           (format-object code4 symbol nil)
           (format code4 "\"),")
           (comp code4 value nil nil nil nil t nil nil)
           (format code4 ");")
           (format code4 "Fset_opt(Fmakesym(\"")
           (format-object code4 symbol nil)
           (format code4 "\"),FAST_GLOBAL);~%")))
    ;defconstant
    (defun comp-defconstant (x)
        (let ((symbol (elt x 1))
              (value (elt x 2)) )
           (format code4 "Fset_cdr(Fmakesym(\"")
           (format-object code4 symbol nil)
           (format code4 "\"),")
           (comp code4 value nil nil nil nil t nil nil)
           (format code4 ");")
           (format code4 "Fset_opt(Fmakesym(\"")
           (format-object code4 symbol nil)
           (format code4 "\"),FAST_CONSTN);~%")))
    ;defdynamic
    (defun comp-defdynamic (x)
        (unless (= (length x) 3) (error* "defdynamic: illegal form" x))
        (unless (symbolp (elt x 1)) (error: "defdynamic: not symbol" (elt x 1)))
        (let ((symbol (elt x 1))
              (value (elt x 2)) )
           (format code4 "Fsetdynenv(Fmakesym(\"")
           (format-object code4 symbol nil)
           (format code4 "\"),")
           (comp code4 value nil nil nil nil t nil nil)
           (format code4 ");")))
    ;set-dynamic
    (defun comp-set-dynamic (stream x env args tail name global test clos)
        (unless (= (length x) 3) (error* "set-dynamic: illegal form" x))
        (unless (symbolp (elt x 1)) (error: "set-dynamic: not symbol" (elt x 1)))
        (let ((symbol (elt x 1))
              (value (elt x 2)) )
           (format stream "Fsetdynamic(Fmakesym(\"")
           (format-object stream symbol nil)
           (format stream "\"),fast_inverse(")
           (comp stream value env args tail name global test clos)
           (format stream "))")))
    ;defmacro
    (defun comp-defmacro (x)
        (format code4 "Feval(")
        (list-to-c1 code4 x)
        (format code4 ");~%"))
    ;defclass
    (defun comp-defclass (x)
        (comp code4 '(ignore-toplevel-check t) nil nil nil nil nil nil nil)
        (format code4 ";Feval(")
        (list-to-c1 code4 x)
        (format code4 ");")
        (comp code4 '(ignore-toplevel-check nil) nil nil nil nil nil nil nil)
        (format code4 ";~%"))
    ;defmethod only create initialize-object
    ;these are nead to save as C-list
    (defun comp-defmethod (x)
        (cond ((or (eq (elt x 1) 'create) (eq (elt x 1) 'initialize-object))
               (format code4 "Feval(")
               (list-to-c1 code4 x)
               (format code4 ");~%"))
              (t
               (let* ((name (elt x 1))
                      (arg (if (listp (elt x 2))
                              (elt x 2)
                              (elt x 3)))
                      (res (assoc name generic-name-arg)) )
                   (when (null res) (error* "not exist defgeneric " name))
                   (unless
                    (has-same-varlis-p arg (cdr res))
                    (error* "args variable name must be same" (list arg (cdr res))))))))
    
    
    (defun has-same-varlis-p (x y)
        (cond ((and (null x) (null y)) t)
              ((and (null x) (not (null y))) nil)
              ((and (not (null x)) (null y)) nil)
              ((and (symbolp (car x)) (symbolp (car y)) (eq (car x) (car y)))
               (has-same-varlis-p (cdr x) (cdr y)))
              ((and (consp (car x)) (consp (car y)) (eq (elt (car x) 0) (elt (car y) 0)))
               (has-same-varlis-p (cdr x) (cdr y)))
              ((and (consp (car x)) (symbolp (car y)) (eq (elt (car x) 0) (car y)))
               (has-same-varlis-p (cdr x) (cdr y)))
              ((and (symbolp (car x)) (consp (car y)) (eq (car x) (elt (car y) 0)))
               (has-same-varlis-p (cdr x) (cdr y)))
              (t nil)))
    
    
    ;;ex prime-factors -> prime_factors
    (defun conv-name (sym)
        (convert (conv-name1 (convert (convert sym <string>) <list>)) <symbol>))
    
    (defun conv-name1 (ls)
        (cond ((char= (car ls) #\0) (string-append "zero" (conv-name2 (cdr ls))))
              ((char= (car ls) #\1) (string-append "one" (conv-name2 (cdr ls))))
              ((char= (car ls) #\2) (string-append "two" (conv-name2 (cdr ls))))
              ((char= (car ls) #\3) (string-append "three" (conv-name2 (cdr ls))))
              ((char= (car ls) #\4) (string-append "four" (conv-name2 (cdr ls))))
              ((char= (car ls) #\5) (string-append "five" (conv-name2 (cdr ls))))
              ((char= (car ls) #\6) (string-append "six" (conv-name2 (cdr ls))))
              ((char= (car ls) #\7) (string-append "seven" (conv-name2 (cdr ls))))
              ((char= (car ls) #\8) (string-append "eight" (conv-name2 (cdr ls))))
              ((char= (car ls) #\9) (string-append "nine" (conv-name2 (cdr ls))))
              (t (conv-name2 ls))))
    
    (defun conv-name2 (ls)
        (cond ((null ls) "")
              ((char= (car ls) #\-) (string-append "_" (conv-name2 (cdr ls))))
              ((char= (car ls) #\+) (string-append "plus" (conv-name2 (cdr ls))))
              ((char= (car ls) #\*) (string-append "star" (conv-name2 (cdr ls))))
              ((char= (car ls) #\/) (string-append "slash" (conv-name2 (cdr ls))))
              ((char= (car ls) #\!) (string-append "exclamation" (conv-name2 (cdr ls))))
              ((char= (car ls) #\%) (string-append "percent" (conv-name2 (cdr ls))))
              ((char= (car ls) #\$) (string-append "dollar" (conv-name2 (cdr ls))))
              ((char= (car ls) #\&) (string-append "and" (conv-name2 (cdr ls))))
              ((char= (car ls) #\=) (string-append "equal" (conv-name2 (cdr ls))))
              ((char= (car ls) #\^) (string-append "hat" (conv-name2 (cdr ls))))
              ((char= (car ls) #\~) (string-append "tilde" (conv-name2 (cdr ls))))
              ((char= (car ls) #\\) (string-append "yen" (conv-name2 (cdr ls))))
              ((char= (car ls) #\|) (string-append "vertical" (conv-name2 (cdr ls))))
              ((char= (car ls) #\@) (string-append "atmark" (conv-name2 (cdr ls))))
              ((char= (car ls) #\#) (string-append "sharp" (conv-name1 (cdr ls))))
              ((char= (car ls) #\:) (string-append "colon" (conv-name2 (cdr ls))))
              ((char= (car ls) #\>) (string-append "greater" (conv-name2 (cdr ls))))
              ((char= (car ls) #\<) (string-append "smaller" (conv-name2 (cdr ls))))
              ((char= (car ls) #\[) (string-append "lbracket" (conv-name2 (cdr ls))))
              ((char= (car ls) #\]) (string-append "rbracket" (conv-name2 (cdr ls))))
              ((char= (car ls) #\{) (string-append "lcurl" (conv-name2 (cdr ls))))
              ((char= (car ls) #\}) (string-append "rcurl" (conv-name2 (cdr ls))))
              ((char= (car ls) #\?) (string-append "question" (conv-name2 (cdr ls))))
              ((char= (car ls) #\.) (string-append "dot" (conv-name2 (cdr ls))))
              (t (string-append (convert (car ls) <string>) (conv-name2 (cdr ls))))))
    
    ;; fixnum translate to immediate
    (defun list-to-c (stream x)
        (cond ((null x) (format stream "NIL"))
              ((fixnump x)
               (format stream "fast_immediate(")
               (format stream (convert x <string>))
               (format stream ")"))
              ((floatp x)
               (format stream "Fmakestrflt(\"")
               (format-float stream x)
               (format stream "\")"))
              ((or (bignump x) (longnump x))
               (format stream "Fmakebig(\"")
               (format-integer stream x 10)
               (format stream "\")"))
              ((stringp x)
               (format stream "Fmakestr(")
               (format-char stream (convert 39 <character>))
               ;;'
               (format-char stream (convert 39 <character>))
               ;;'
               (format-object stream x nil)
               (format-char stream (convert 39 <character>))
               ;;'
               (format-char stream (convert 39 <character>))
               ;;'
               (format stream ")"))
              ((characterp x)
               (cond ((or
                       (char= x #\\)
                       (char= x (convert 34 <character>))
                       ;;"
                       (char= x (convert 39 <character>)))
                      ;;'
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream #\\)
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format stream ")"))
                     (t
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format stream ")"))))
              ((general-vector-p x)
               (format stream "Fvector(")
               (list-to-c1 stream (convert x <list>))
               (format stream ")"))
              ((general-array*-p x)
               (format stream "Farray(")
               (format-integer stream (length (array-dimensions x)) 10)
               (format stream ",")
               (list-to-c1 stream (readed-array-list x))
               (format stream ")"))
              ((symbolp x)
               (cond ((eq x t) (format stream "T"))
                     ((eq x nil) (format stream "NIL"))
                     (t
                      (format stream "Fmakesym(\"")
                      (format stream (convert x <string>))
                      (format stream "\")"))))
              ((stringp x)
               (format stream "Fmakestr(\"")
               (format-object stream x nil)
               (format stream "\")"))
              (t
               (format stream "Fcons(")
               (list-to-c stream (car x))
               (format stream ",")
               (list-to-c stream (cdr x))
               (format stream ")"))))
    
    ;;translate fixnum to int-cell
    (defun list-to-c1 (stream x)
        (cond ((null x) (format stream "NIL"))
              ((fixnump x)
               (format stream "Fmakeint(")
               (format stream (convert x <string>))
               (format stream ")"))
              ((floatp x)
               (format stream "Fmakestrflt(\"")
               (format-float stream x)
               (format stream "\")"))
              ((or (bignump x) (longnump x))
               (format stream "Fmakebig(\"")
               (format-integer stream x 10)
               (format stream "\")"))
              ((stringp x)
               (format stream "Fmakestr(")
               (format-char stream (convert 39 <character>))
               ;;'
               (format-char stream (convert 39 <character>))
               ;;'
               (format-object stream x nil)
               (format-char stream (convert 39 <character>))
               ;;'
               (format-char stream (convert 39 <character>))
               ;;'
               (format stream ")"))
              ((characterp x)
               (cond ((or
                       (char= x #\\)
                       (char= x (convert 34 <character>))
                       ;;"
                       (char= x (convert 39 <character>)))
                      ;;'
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream #\\)
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format stream ")"))
                     ((special-char-p x)
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (print-special-char x stream)
                      (format-char stream (convert 39 <character>))                        ;'
                      (format-char stream (convert 39 <character>))                        ;'
                      (format stream ")"))
                     (t
                      (format stream "Fmakechar(")
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream x)
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format-char stream (convert 39 <character>))
                      ;;'
                      (format stream ")"))))
              ((general-vector-p x)
               (format stream "Fvector(")
               (list-to-c1 stream (convert x <list>))
               (format stream ")"))
              ((general-array*-p x)
               (format stream "Farray(")
               (format-integer stream (length (array-dimensions x)) 10)
               (format stream ",")
               (list-to-c1 stream (readed-array-list x))
               (format stream ")"))
              ((symbolp x)
               (cond ((eq x t) (format stream "T"))
                     ((eq x nil) (format stream "NIL"))
                     (t
                      (format stream "Fmakesym(\"")
                      (format stream (convert x <string>))
                      (format stream "\")"))))
              ((stringp x)
               (format stream "Fmakestr(\"")
               (format-object stream x nil)
               (format stream "\")"))
              (t
               (format stream "Fcons(")
               (list-to-c1 stream (car x))
               (format stream ",")
               (list-to-c1 stream (cdr x))
               (format stream ")"))))
    
    
    ;;quasi-quote
    (defun quasi-transfer (x n)
        (cond ((null x) nil)
              ((atom x) (list 'quote x))
              ((and (consp x) (eq (car x) 'unquote) (= n 0)) (elt x 1))
              ((and (consp x) (eq (car x) 'unquote-splicing) (= n 0)) (elt x 1))
              ((and (consp x) (eq (car x) 'quasi-quote))
               (list 'list (list 'quote 'quasi-quote) (quasi-transfer (elt x 1) (+ n 1))))
              ((and (consp x) (consp (car x)) (eq (car (car x)) 'unquote) (= n 0))
               (list 'cons (elt (car x) 1) (quasi-transfer (cdr x) n)))
              ((and (consp x) (consp (car x)) (eq (car (car x)) 'unquote-splicing) (= n 0))
               (list 'append (elt (car x) 1) (quasi-transfer (cdr x) n)))
              ((and (consp x) (consp (car x)) (eq (car (car x)) 'unquote))
               (list
                'cons
                (list 'list (list 'quote 'unquote) (quasi-transfer (elt (car x) 1) (- n 1)))
                (quasi-transfer (cdr x) n)))
              ((and (consp x) (consp (car x)) (eq (car (car x)) 'unquote-splicing))
               (list
                'cons
                (list
                 'list
                 (list 'quote 'unquote-splicing)
                 (quasi-transfer (elt (car x) 1) (- n 1)))
                (quasi-transfer (cdr x) n)))
              (t (list 'cons (quasi-transfer (car x) n) (quasi-transfer (cdr x) n)))))
    
    
    ;;-----------type inferrence-------------
    ;;if following all test is true, it is optimizable
    ;;output type is fixnum or float
    ;;input type is all fixnum or float,
    ;;if it has local function,the output type and input types are
    ;;fixnum or float
    (defun optimize-p (x)
        (if (> (length x) 1)
            (let* ((fn (elt x 1))
                   (dt (assoc fn type-function)) )
                (cond ((null dt) nil)
                      ((and
                        (eq (elt x 0) 'defun)
                        (member (elt dt 1) (list (class <fixnum>) (class <float>)))
                        (subsetp (elt dt 2) (list (class <fixnum>) (class <float>)))
                        (optimize-p1 (cdr (cdr (cdr dt)))))
                       t)
                      (t nil)))
            nil))
    
    
    ;;local type is optimizable?
    (defun optimize-p1 (x)
        (cond ((null x) t)
              ((and
                (member (elt (car x) 1) (list (class <fixnum>) (class <float>)))
                (subsetp (elt (car x) 2) (list (class <fixnum>) (class <float>))))
               (optimize-p1 (cdr x)))
              (t nil)))
    
    ;;global function, return output type
    (defun return-type (x)
        (elt (assoc x type-function) 1))
    
    ;;global function, return input argument type
    (defun argument-type (x)
        (elt (assoc x type-function) 2))
    
    ;;local function, return output type
    ;;x is global name, y is local name
    (defun local-return-type (x y)
        (let ((local (elt (assoc x type-function) 3)))
           (elt (assoc y local) 1)))
    
    ;;local function, return input argument type
    ;;x is global name, y is local name
    (defun local-argument-type (x y)
        (let ((local (elt (assoc x type-function) 3)))
           (elt (assoc y local) 2)))
    
    ;; (x y z) -> (int x, double y, int z) when (<fixnum> <float> <fixnum>)
    ;; output to stream of string
    (defun type-gen-arg2 (stream ls type)
        (format stream "(")
        (if (null ls)
            (format stream ")")
            (for ((ls1 ls (cdr ls1))
                  (n 0 (+ n 1)) )
                 ((null (cdr ls1))
                  (cond ((eq (elt type n) (class <fixnum>))
                        (format stream "int ")
                        (format-object stream (conv-name (car ls1)) nil)
                        (format stream ")"))
                       ((eq (elt type n) (class <float>))
                        (format stream "double ")
                        (format-object stream (conv-name (car ls1)) nil)
                        (format stream ")"))) )
                 (cond ((eq (elt type n) (class <fixnum>))
                        (format stream "int ")
                        (format-object stream (conv-name (car ls1)) nil)
                        (format stream ","))
                       ((eq (elt type n) (class <float>))
                        (format stream "double ")
                        (format-object stream (conv-name (car ls1)) nil)
                        (format stream ","))))))
    
    ;;for tail call
    ;; when ls=(<fixnum> <float> <fixnum>) -> int temp1; double temp2; int temp3;
    (defun type-gen-arg3 (n ls)
        (unless
         (= n 0)
         (for ((m 1 (+ m 1)))
              ((> m n)
               (format code2 "~%") )
              (cond ((eq (car ls) (class <fixnum>)) (format code2 "int "))
                    ((eq (car ls) (class <float>)) (format code2 "double ")))
              (format code2 "temp")
              (format code2 (convert m <string>))
              (format code2 ";"))))
    
    
    ;;(foo arg1 arg2) ->
    ;;  return(F_makeint(foo(Fgetint(arg1),Fgetint(arg2))));
    (defun type-gen-call (name n)
        (let ((name1 (conv-name name))
              (return (return-type name))
              (argument (argument-type name)) )
           (cond ((= n 0)
                  (cond ((eq return (class <fixnum>))
                         (format code1 "return(Fmakeint(")
                         (format code1 (convert name1 <string>))
                         (format code1 "() ));~%"))
                        ((eq return (class <float>))
                         (format code1 "return(Fmakedoubleflt(")
                         (format code1 (convert name1 <string>))
                         (format code1 "() ));~%"))))
                 (t
                  (cond ((eq return (class <fixnum>))
                         (format code1 "return(Fmakeint(")
                         (format code1 (convert name1 <string>))
                         (format code1 "("))
                        ((eq return (class <float>))
                         (format code1 "return(Fmakedoubleflt(")
                         (format code1 (convert name1 <string>))
                         (format code1 "(")))
                  (for ((m 1 (+ m 1)))
                       ((= m n)
                        (cond ((eq (elt argument (- m 1)) (class <fixnum>))
                              (format code1 "Fgetint(arg")
                              (format code1 (convert m <string>))
                              (format code1 "))));~%"))
                             ((eq (elt argument (- m 1)) (class <float>))
                              (format code1 "Fgetflt(arg")
                              (format code1 (convert m <string>))
                              (format code1 "))));~%"))) )
                       (cond ((eq (elt argument (- m 1)) (class <fixnum>))
                              (format code1 "Fgetint(arg")
                              (format code1 (convert m <string>))
                              (format code1 "),"))
                             ((eq (elt argument (- m 1)) (class <float>))
                              (format code1 "Fgetflt(arg")
                              (format code1 (convert m <string>))
                              (format code1 "),"))))))))
    
    
    (defun subsetp (x y)
        (cond ((null x) t)
              ((member (car x) y) (subsetp (cdr x) y))
              (t nil)))
    
    (defmacro assert (sym :rest class)
        `(set-property (list (mapcar #'eval ',class)) ',sym 'inference))
    
    (defmacro assertz (sym :rest class)
        `(let
          ((old (property ',sym 'inference)))
          (set-property (append old (list (mapcar #'eval ',class))) ',sym 'inference)))
    
    (defun class-dynamic (c)
        (cond ((eq c '<string>) (class <string>))
              ((eq c '<list>) (class <list>))
              ((eq c '<number>) (class <number>))
              ((eq c '<vector>) (class <vector>))
              ((eq c '<float>) (class <float>))
              (t (class <object>))))
    
    
    ;;type-function ((name output-type (input-type1 input-typr2 ...) (local-type-function)) ...)
    (defglobal file-name-and-ext nil)
    (defglobal instream nil)
    (defglobal type-function nil)
    ;; for global defun
    (defglobal local-type-function nil)
    ;;for lavels flet syntax
    (defun warning (str x)
        (format (standard-output) "warning ~A ~A ~A~%" inference-name str x))
    
    ;;type inference s-expression(s) in file x.
    ;;x is string of filename.
    (defun inference-file (x)
        (format (standard-output) "type inference~%")
        (setq file-name-and-ext x)
        (setq type-function nil)
        (setq instream (open-input-file x))
        (let ((sexp nil))
           (while (setq sexp (read instream nil nil))
              (cond ((and (consp sexp) (eq (car sexp) 'defun)) (inference-defun sexp)))
              (cond ((and (consp sexp) (eq (car sexp) 'defmodule)) (inference-defmodule sexp))))
           (close instream)
           (setq instream nil))
        t)
    
    (defun inference-defmodule (x)
        (for ((name (car (cdr x)))
              (body (cdr (cdr x)) (cdr body)))
             ((null body) t)
             (let ((sexp (substitute (car body) name nil)))
                (if (and (consp sexp) (eq (car sexp) 'defun))
                    (inference-defun sexp)))))

    
    (defun inference-defun (x)
        (let* ((name (elt x 1))
               (arg (elt x 2))
               (body (cdr (cdr (cdr x))))
               (init-type-input (create-list (length arg) (class <object>)))
               (init-env (create-init-env arg)) )
            (setq inference-name name)
            (setq type-function (cons (list name (class <object>) init-type-input) type-function))
            (let ((type-env (inference-all body init-env name nil)))
               (if (not (eq type-env 'no))
                   (set-type-function-input name (find-argument-class arg type-env)))
               (if (not (null local-type-function))
                   (add-type-function-local name)))))
    
    
    (defun inference-labels (x type-env)
        (setq local-type-function nil)
        (let ((labels-func (elt x 1))
              (labels-body (cdr (cdr x)))
              (local-type-env nil) )
           (while (not (null labels-func))
              (let* ((func (car labels-func))
                     (name (elt func 0))
                     (arg (elt func 1))
                     (body (cdr (cdr func)))
                     (init-type-input (create-list (length arg) (class <object>)))
                     (init-env (create-init-env arg)) )
                  (setq
                   local-type-function
                   (cons (list name (class <object>) init-type-input) local-type-function))
                  (setq
                   local-type-env
                   (inference-all (append labels-body body) (append init-env type-env) name t))
                  (if (not (eq local-type-env 'no))
                      (set-local-type-function-input name (find-argument-class arg local-type-env)))
                  (setq labels-func (cdr labels-func))))
           local-type-env))
    
    
    ;;transform from data in ls to class data.
    (defun find-argument-class (ls type-env)
        (for ((arg ls (cdr arg))
              (result nil) )
             ((null arg)
              (reverse result) )
             (setq result (cons (find-class (car arg) type-env) result))))
    
    ;;create list that length is length of ls. all element is <object>
    (defun create-init-env (ls)
        (for ((arg ls (cdr arg))
              (result nil) )
             ((null arg)
              (reverse result) )
             (setq result (cons (cons (car arg) (class <object>)) result))))
    
    ;; inference a s-expression
    ;; if x is true return type-env else return 'no
    (defun inference (x type-env)
        (cond ((and (symbolp x) (eq x t)) type-env)
              ((and (symbolp x) (eq x nil)) type-env)
              ((symbolp x)
               (let ((y (refer x type-env)))
                  (if y
                      type-env
                      (unify x (class <object>) type-env))))
              ((atom x) type-env)
              ((and (consp x) (eq (car x) 'the)) (unify (class* (elt x 1)) (elt x 2) type-env))
              ((and (consp x) (eq (car x) 'not))                                           ; ignore not function
               type-env)
              ((and (consp x) (eq (car x) 'setq))
               (cond ((not (symbolp (elt x 1))) (warning "setq type mismatch" (elt x 1)) type-env)
                     (t (cons (cons (elt x 1) (find-class (elt x 2) type-env)) type-env))))
              ((and (consp x) (eq (car x) 'convert))                                       ; ignore convert function
               type-env)
              ((and (consp x) (eq (car x) 'catch)) (inference (elt x 2) type-env))
              ((and (consp x) (eq (car x) 'throw)) (inference (elt x 2) type-env))
              ((and (consp x) (eq (car x) 'quote)) type-env)
              ((and (consp x) (eq (car x) 'cond)) (inference-cond x type-env))
              ((and (consp x) (eq (car x) 'case)) (inference-case x type-env))
              ((and (consp x) (eq (car x) 'if)) (inference-if x type-env))
              ((and (consp x) (eq (car x) 'let)) (inference-let x type-env))
              ((and (consp x) (eq (car x) 'let*)) (inference-let x type-env))
              ((and (consp x) (eq (car x) 'for)) (inference-for x type-env))
              ((and (consp x) (eq (car x) 'while)) (inference-while x type-env))
              ((and (consp x) (eq (car x) 'labels)) (inference-labels x type-env))
              ((and (consp x) (eq (car x) 'flet)) (inference-labels x type-env))
              ((and (consp x) (eq (car x) 'function)) (inference-function x type-env))
              ((and (consp x) (macrop x)) (inference (macroexpand-1 x) type-env))
              ((and (consp x) (member (car x) '(+ - * = > < >= <= /=)))
               (inference-numeric x type-env))
              ((and (consp x) (subrp (car x)))
               (let ((type-subr (property (car x) 'inference)))
                  (block exit-inference
                     (for ((type type-subr (cdr type)))
                          ((null type)
                           (warning "subr type mismatch" x)
                           'no )
                          (let ((new-env (inference-arg (cdr x) (cdr (car type)) type-env)))
                             (if (not (eq new-env 'no))
                                 (return-from exit-inference new-env)))))))
              ((consp x)
               (let ((type (find-function-type (car x))))
                  (if type
                      (inference-arg (cdr x) (elt type 1) type-env))))
              (t (warning "can't inference " x) 'no)))
    
    
    ;; inference s-expressions
    ;; if all success return type-env else return 'no
    (defun inference-all (x type-env fn local)
        (let ((result (inference-all1 x type-env fn)))
           (cond ((and (not (eq result 'no)) (not local))
                  (set-type-function-output fn (find-class (last x) result)))
                 ((and (not (eq result 'no)) local)
                  (set-local-type-function-output fn (find-class (last x) result))))
           result))
    
    (defun inference-all1 (x type-env fn)
        (cond ((null x) type-env)
              ((and (consp (car x)) (member (car (car x)) '(+ - * = > < >= <= /=)))
               (let ((new-env (inference (car x) type-env)))
                  (cond (new-env (inference-all1 (cdr x) new-env fn))
                        (t (warning "numeric type mismatch" x) 'no))))
              ((and (consp (car x)) (subrp (car (car x))))
               (let ((type-subr (property (car (car x)) 'inference)))
                  (block exit-all
                     (for ((type type-subr (cdr type)))
                          ((null type)
                           (warning "subr type mismatch" (car x))
                           'no )
                          (let ((new-env (inference-arg (cdr (car x)) (cdr (car type)) type-env)))
                             (if (not (eq new-env 'no))
                                 (let ((result (inference-all1 (cdr x) new-env fn)))
                                    (if (not (eq result 'no))
                                        (return-from exit-all result)))))))))
              (t
               (let ((new-env (inference (car x) type-env)))
                  (cond ((eq new-env 'no) (warning "type mismatch" (car x)) 'no)
                        (t (inference-all1 (cdr x) new-env fn)))))))
    
    ;;cond syntax
    (defun inference-cond (x type-env)
        (inference-cond1 (cdr x) type-env))
    
    (defun inference-cond1 (x type-env)
        (cond ((null x) type-env)
              (t
               (let ((new-env (inference-cond2 (car x) type-env)))
                  (cond ((not (eq new-env 'no)) (inference-cond1 (cdr x) type-env))
                        (t (warning "cond mismatch" (car x)) (inference-cond1 (cdr x) type-env)))))))
    
    (defun inference-cond2 (x type-env)
        (cond ((null x) type-env)
              (t
               (let ((new-env (inference (car x) type-env)))
                  (cond ((not (eq new-env 'no)) (inference-cond2 (cdr x) new-env))
                        (t (warning "cond mismatch" x) (inference-cond2 (cdr x) type-env)))))))
    
    ;;case syntax
    (defun inference-case (x type-env)
        (inference-case1 (cdr (cdr x)) type-env))
    
    (defun inference-case1 (x type-env)
        (cond ((null x) type-env)
              (t
               (let ((new-env (inference-case2 (cdr (car x)) type-env)))
                  (if (not (eq new-env 'no))
                      (inference-case1 (cdr x) new-env)
                      (warning "case mismatch" x))))))
    
    (defun inference-case2 (x type-env)
        (if (null x)
            type-env
            (inference-case2 (cdr x) (inference (car x) type-env))))
    
    ;;if syntax
    (defun inference-if (x type-env)
        (if (= (length x) 4)
            (inference-if1 x type-env)
            (inference-if2 x type-env)))
    
    ;;(if test true else)
    (defun inference-if1 (x type-env)
        (let ((test (inference (elt x 1) type-env)))
           (if (not (eq test 'no))
               (let ((else (inference (elt x 3) test)))
                  (if (not (eq else 'no))
                      (let ((true (inference (elt x 2) else)))
                         (if (not (eq true 'no))
                             true
                             (progn (warning "if mismatch" x) 'no)))
                      'no))
               'no)))
    
    ;;(if test true)
    (defun inference-if2 (x type-env)
        (let ((test (inference (elt x 1) type-env)))
           (if (not (eq test 'no))
               (let ((true (inference (elt x 2) test)))
                  (if (not (eq true 'no))
                      true
                      (progn (warning "if mismatch" x) 'no)))
               'no)))
    
    ;; +-* ...
    (defun inference-numeric (x type-env)
        (cond ((every
                (lambda (x)
                   (let ((type (find-class x type-env)))
                      (or
                       (null type)
                       (eq type (class <object>))
                       (eq type (class <number>))
                       (eq type (class <longnum>))
                       (eq type (class <bignum>)))))
                (cdr x))
               (estimate (cdr x) (class <number>) type-env))
              ((every (lambda (x)
                         (eq (class <fixnum>) (find-class x type-env))) (cdr x)) type-env)
              ((any (lambda (x)
                       (eq (class <float>) (find-class x type-env))) (cdr x))
               (estimate (cdr x) (class <float>) type-env))
              ((any (lambda (x)
                       (eq (class <integer>) (find-class x type-env))) (cdr x))
               (estimate (cdr x) (class <integer>) type-env))
              ((any (lambda (x)
                       (eq (class <fixnum>) (find-class x type-env))) (cdr x))
               (estimate (cdr x) (class <integer>) type-env))
              (t (warning "numerical argument type mismatch" x) 'no)))
    
    ;;let syntax
    (defun inference-let (x type-env)
        (let ((vars (elt x 1))
              (body (cdr (cdr x))) )
           (if (null vars)
               (inference-all1 body type-env nil)
               (block exit-let
                  (for ((vars1 vars (cdr vars1)))
                       ((null vars1))
                       (setq type-env (unify (elt (car vars1) 0) (elt (car vars1) 1) type-env))
                       (if (eq type-env 'no)
                           (return-from exit-let 'no)))
                  (inference-all1 body type-env nil)))))
    
    ;;for syntax
    (defun inference-for (x type-env)
        (let ((vars (elt x 1))
              (end (elt x 2))
              (body (cdr (cdr (cdr x)))) )
           (block exit-for
              (for ((vars1 vars (cdr vars1)))
                   ((null vars1))
                   (setq type-env (inference (car vars1) type-env))
                   (if (eq type-env 'no)
                       (return-from exit-for 'no)))
              (for ((end1 end (cdr end1)))
                   ((null end1))
                   (setq type-env (inference (car end1) type-env))
                   (if (eq type-env 'no)
                       (return-from exit-for 'no)))
              (inference-all1 body type-env nil))))
    
    (defun inference-while (x type-env)
        (inference-while1 (cdr x) type-env))
    
    (defun inference-while1 (x type-env)
        (cond ((null x) type-env)
              (t (inference-while1 (cdr x) (inference (car x) type-env)))))
    
    (defun inference-function (x type-env)
        (let ((new-env (unify (car (cdr x)) (class <symbol>) type-env)))
           (cond ((eq new-env 'no) (warning "function mismatch" x) type-env)
                 (t new-env))))
    
    
    ;;find type-data of user defined function.
    ;;first look for in type-function environment
    ;;second look for int local-type-function environment
    ;;return list as (output-class (input-class ...))
    (defun find-function-type (x)
        (let ((y (assoc x type-function)))
           (if (null y)
               (let ((z (assoc x local-type-function)))
                  (if (null z)
                      nil
                      (cdr z)))
               (cdr y))))
    
    ;;if argument is atom, unify the atom and type of argument.
    ;;else if argument is cons, inference the cons.
    ;;and unify the cons and type of argument.
    (defun inference-arg (x y type-env)
        (block exit-arg
           (for ((arg x (cdr arg))
                 (type
                 y
                 (if (and (>= (length type) 2) (eq (elt type 1) 'repeat))                     ;e.g. funcall
                     type
                     (cdr type))) )
                ((or (null arg) (null type))
                 (cond ((and (null arg) (null type)) type-env)
                      ((and (null arg) (and (>= (length type) 2) (eq (elt type 1) 'repeat)))
                       type-env)
                      (t 'no)) )
                (cond ((atom (car arg))
                       (let ((new-env (unify (car arg) (car type) type-env)))
                          (if (eq new-env 'no)
                              (return-from exit-arg 'no)
                              (setq type-env new-env))))
                      (t
                       (let ((new-env (inference (car arg) type-env)))
                          (cond ((eq new-env 'no) (return-from exit-arg 'no))
                                (t
                                 (let ((output-class (find-class (car arg) type-env)))
                                    (if (not
                                         (or
                                          (eq output-class (car type))
                                          (subclassp output-class (car type))
                                          (subclassp (car type) output-class)))
                                        (return-from exit-arg 'no)))))
                          (setq type-env new-env)))))))
    
    
    ;;if x is registed in type-function data,
    ;;return t (if the output-class is <object>)
    ;;return nil (if the output-class is not <object>)
    (defun function-type-object-p (x)
        (let ((y (assoc (elt x 1) type-function)))
           (if (not y)
               nil
               (eq (elt y 0) (class <object>)))))
    
    ;;find class of s-exp
    (defun find-class (x type-env)
        (cond ((null x) (class <null>))
              ((and (symbolp x) (eq x 't)) (class <symbol>))
              ((symbolp x) (refer x type-env))
              ((atom x) (class-of x))
              ((and (consp x) (member (car x) '(+ - * = > < >= <= /=)))
               (find-class-numeric x type-env))
              ((and (consp x) (subrp (car x)))
               (let ((type-subr (property (car x) 'inference)))
                  (car (car type-subr))))
              ((and (consp x) (type-function-p (car x))) (elt (find-function-type (car x)) 0))
              ((and (consp x) (eq (car x) 'labels)) (find-class (last (elt x 2)) type-env))
              ((and (consp x) (eq (car x) 'flet)) (find-class (last (elt x 2)) type-env))
              ((and (consp x) (eq (car x) 'cond)) (find-class-cond (cdr x) type-env))
              ((and (consp x) (eq (car x) 'if)) (find-class-if x type-env))
              ((and (consp x) (eq (car x) 'quote)) (class-of (elt x 1)))
              ((and (consp x) (eq (car x) 'the)) nil)
              ((and (consp x) (eq (car x) 'setq)) (find-class (elt x 1) type-env))
              ((and (consp x) (eq (car x) 'convert)) (class-dynamic (elt x 2)))
              ((and (consp x) (eq (car x) 'catch)) (find-class (elt x 1) type-env))
              ((and (consp x) (eq (car x) 'throw)) (find-class (elt x 2) type-env))
              ((and (consp x) (eq (car x) 'let)) (find-class (last (cdr (cdr x))) type-env))
              ((and (consp x) (eq (car x) 'let*)) (find-class (last (cdr (cdr x))) type-env))
              ((and (consp x) (eq (car x) 'while)) (class <null>))
              ((and (consp x) (eq (car x) 'lambda)) (class <function>))
              ((and (consp x) (macrop x)) (find-class (macroexpand-1 x) type-env))
              ((consp x) (class <object>))
              (t (class <object>))))
    
    (defun find-class-if (x type-env)
        (find-class (elt x 2) type-env))
    
    (defun find-class-cond (x type-env)
        (cond ((null x) (class <object>))
              (t (find-class (last (car x)) type-env))))
    
    (defun find-class-numeric (x type-env)
        (cond ((every
                (lambda (x)
                   (let ((type (find-class x type-env)))
                      (or (null type) (eq type (class <object>)))))
                (cdr x))
               (class <number>))
              ((every (lambda (x)
                         (eq (class <fixnum>) (find-class x type-env))) (cdr x))
               (class <fixnum>))
              ((any (lambda (x)
                       (eq (class <float>) (find-class x type-env))) (cdr x))
               (class <float>))
              ((any (lambda (x)
                       (eq (class <integer>) (find-class x type-env))) (cdr x))
               (class <integer>))
              ((any (lambda (x)
                       (eq (class <fixnum>) (find-class x type-env))) (cdr x))
               (class <integer>))
              (t (class <number>))))
    
    
    ;;reference symbol x in type-env
    (defun refer (x type-env)
        (let ((y (assoc x type-env)))
           (cond ((null y) (class <object>))
                 (t (cdr y)))))
    
    ;;assign type destructive in type-function
    ;;set output class
    (defun set-type-function-output (fn y)
        (let ((z (assoc fn type-function)))
           (setf (elt z 1) y)))
    
    ;;set input class
    (defun set-type-function-input (fn y)
        (let ((z (assoc fn type-function)))
           (setf (elt z 2) y)))
    
    ;;add local function type data
    (defun add-type-function-local (fn)
        (let ((z (assoc fn type-function)))
           (append! z (list local-type-function))))
    
    ;;local type-function
    ;;assign type destructive in local-type-function
    ;;set output class
    (defun set-local-type-function-output (fn y)
        (let ((z (assoc fn local-type-function)))
           (setf (elt z 1) y)))
    
    ;;set input class
    (defun set-local-type-function-input (fn y)
        (let ((z (assoc fn local-type-function)))
           (setf (elt z 2) y)))
    
    
    ;;if x is registed in type-function return not nil
    ;;elt return nil
    (defun type-function-p (x)
        (assoc x type-function))
    
    ;;if eq(x,y) subclassp(x,y) or subclassp(y,x),then unify is success
    ;;if success return type-env else return 'no.
    ;;type-env  ((x . (class integer))(x . (class <number>))(x . y))
    ;;first x unify number-class,second x unify integer-class.
    (defun unify (x y type-env)
        (cond ((and (not (variablep x)) (not (variablep y)))
               (let ((x1 (if (not (classp x))
                            (find-class x type-env)
                            x))
                     (y1 (if (not (classp y))
                            (find-class y type-env)
                            y)) )
                  (if (or (eq x1 y1) (subclassp* x1 y1) (subclassp* y1 x1))
                      type-env
                      'no)))
              ((and (variablep x) (not (variablep y)))
               (let ((x1 (refer x type-env))
                     (y1 (if (not (classp y))
                            (find-class y type-env)
                            y)) )
                  (cond ((null x1) (setq type-env (cons (cons x y1) type-env)) type-env)
                        ((eq x1 y1) type-env)
                        ((subclassp* x1 y1) type-env)
                        ((subclassp* y1 x1) (cons (cons x y1) type-env))
                        (t 'no))))
              ((and (not (variablep x)) (variablep y))
               (let ((x1 (if (not (classp x))
                            (find-class x type-env)
                            x))
                     (y1 (refer y type-env)) )
                  (cond ((null y1) (setq type-env (cons (cons y x1) type-env)) type-env)
                        ((eq x1 y1) type-env)
                        ((subclassp* x1 y1) (cons (cons y x1) type-env))
                        ((subclassp* y1 x1) type-env)
                        (t 'no))))
              (t (setq type-env (cons (cons x y) type-env)) type-env)))
    
    ;;symbol is variable in unify.
    ;;but nil and t are not variable.
    (defun variablep (x)
        (and (symbolp x) (not (null x)) (not (eq x t))))
    
    (defun subclassp* (x y)
        (cond ((or (eq x nil) (eq x t) (eq y nil) (eq y t)) nil)
              (t (subclassp x y))))
    
    ;;unify all data in ls with class.
    (defun estimate (ls class type-env)
        (for ((ls1 ls (cdr ls1)))
             ((null ls1)
              type-env )
             (cond ((not (symbolp (car ls1))) t)
                   (t (setq type-env (unify (car ls1) class type-env))))))
    
    (defun class* (x)
        (symbol-class x))
    
    ;;subr type data
    ;;       fn          output           input
    (assert parse-number (class <number>) (class <string>))
    (assert sin (class <float>) (class <number>))
    (assert cos (class <float>) (class <number>))
    (assert tan (class <float>) (class <number>))
    (assert atan (class <float>) (class <number>))
    (assert atan2 (class <float>) (class <number>) (class <number>))
    (assert sinh (class <float>) (class <number>))
    (assert cosh (class <float>) (class <number>))
    (assert tanh (class <float>) (class <number>))
    (assert floor (class <integer>) (class <number>))
    (assert ceiling (class <integer>) (class <number>))
    (assert truncate (class <integer>) (class <number>))
    (assert round (class <integer>) (class <number>))
    (assert mod (class <integer>) (class <integer>) (class <integer>))
    (assert div (class <integer>) (class <number>) (class <number>))
    (assert gcd (class <integer>) (class <integer>) (class <integer>))
    (assert lcm (class <integer>) (class <integer>) (class <integer>))
    (assert isqrt (class <number>) (class <integer>))
    (assert char= (class <object>) (class <character>) (class <character>))
    (assert char/= (class <object>) (class <character>) (class <character>))
    (assert char< (class <object>) (class <character>) (class <character>))
    (assert char> (class <object>) (class <character>) (class <character>))
    (assert char<= (class <object>) (class <character>) (class <character>))
    (assert char>= (class <object>) (class <character>) (class <character>))
    (assert quotient (class <number>) (class <number>) (class <number>))
    (assert reciprocal (class <number>) (class <number>))
    (assert max (class <number>) (class <number>) 'repeat)
    (assert min (class <number>) (class <number>) 'repeat)
    (assert abs (class <number>) (class <number>))
    (assert exp (class <number>) (class <number>))
    (assert log (class <number>) (class <number>))
    (assert expt (class <number>) (class <number>) (class <number>))
    (assert sqrt (class <number>) (class <number>))
    (assert cons (class <object>) (class <object>) (class <object>))
    (assert car (class <object>) (class <list>))
    (assert cdr (class <object>) (class <list>))
    (assert set-car (class <null>) (class <object>) (class <list>))
    (assert set-cdr (class <null>) (class <object>) (class <list>))
    (assert create-list (class <list>))
    (assertz create-list (class <list>) (class <integer>))
    (assert list (class <list>) (class <object>) 'repeat)
    (assert reverse (class <list>) (class <list>))
    (assert nreverse (class <list>) (class <list>))
    (assert assoc (class <list>) (class <object>) (class <list>))
    (assert member (class <object>) (class <object>) (class <list>))
    (assert mapcar (class <list>) (class <function>) (class <list>) 'repeat)
    (assert mapc (class <list>) (class <function>) (class <list>) 'repeat)
    (assert mapcan (class <list>) (class <function>) (class <list>) 'repeat)
    (assert maplist (class <list>) (class <function>) (class <list>) 'repeat)
    (assert mapcl (class <list>) (class <function>) (class <list>) 'repeat)
    (assert mapcon (class <list>) (class <function>) (class <list>) 'repeat)
    (assert create-array (class <basic-array>) (class <list>) (class <object>) 'repeat)
    (assert array-dimensions (class <list>) (class <basic-array>))
    (assert create-vector (class <general-vector>) (class <integer>))
    (assert vector (class <general-vector>) (class <object>) 'repeat)
    (assert create-string (class <string>) (class <integer>) (class <object>) 'repeat)
    (assert string= (class <object>) (class <string>) (class <string>))
    (assert string/= (class <object>) (class <string>) (class <string>))
    (assert string< (class <object>) (class <string>) (class <string>))
    (assert string> (class <object>) (class <string>) (class <string>))
    (assert string>= (class <object>) (class <string>) (class <string>))
    (assert string<= (class <object>) (class <string>) (class <string>))
    (assert funcall (class <object>) (class <function>) (class <object>) 'repeat)
    (assert char-index (class <object>) (class <character>))
    (assertz char-index (class <object>) (class <character>) (class <integer>))
    (assert string-index (class <object>) (class <string>) (class <string>))
    (assertz string-index (class <object>) (class <string>) (class <string>) (class <integer>))
    (assert length (class <integer>) (class <list>))
    (assertz length (class <integer>) (class <general-vector>))
    (assertz length (class <integer>) (class <string>))
    (assert elt (class <object>) (class <list>) (class <integer>))
    (assertz elt (class <object>) (class <general-vector>) (class <integer>))
    (assertz elt (class <object>) (class <string>) (class <integer>))
    (assert null (class <symbol>) (class <object>))
    (assert eq (class <symbol>) (class <object>) (class <object>))
    (assert not (class <object>) (class <object>))
    (assert format (class <null>) (class <stream>) (class <string>))
    (assertz format (class <null>) (class <stream>) (class <string>) (class <object>) 'repeat)
    (assert format-integer (class <null>) (class <stream>) (class <integer>) 'repeat)
    (assert format-float (class <null>) (class <stream>) (class <float>) 'repeat)
    (assert format-char (class <null>) (class <stream>) (class <character>) 'repeat)
    (assert format-object (class <null>) (class <stream>) (class <object>) 'repeat)
    (assert format-tab (class <null>) (class <stream>) (class <object>))
    (assert format-fresh-line (class <null>) (class <stream>))
    (assert standard-input (class <stream>))
    (assert standard-output (class <stream>))
    (assert system (class <string>))
    (assert open-input-file (class <string>))
    (assert open-output-file (class <stream>) (class <string>))
    (assert open-io-file (class <string>))
    (assert eval (class <object>) (class <object>))
    (assert atom (class <object>) (class <object>))
    (assert consp (class <object>) (class <object>))
    (assert symbolp (class <object>) (class <object>))
    (assert listp (class <object>) (class <object>))
    (assert consp (class <object>) (class <object>))
    (assert numberp (class <object>) (class <object>))
    (assert integerp (class <object>) (class <object>))
    (assert floatp (class <object>) (class <object>))
    (assert fixnump (class <object>) (class <object>))
    (assert longnump (class <object>) (class <object>))
    (assert bignump (class <object>) (class <object>))
    (assert stringp (class <object>) (class <object>))
    (assert characterp (class <object>) (class <object>))
    (assert functionp (class <object>) (class <object>))
    (assert general-vector-p (class <object>) (class <object>))
    (assert general-array*-p (class <object>) (class <object>))
    (assert property (class <object>) (class <symbol>) (class <symbol>))
    (assert set-property (class <object>) (class <object>) (class <symbol>) (class <symbol>))
    (assert read (class <object>))
    (assertz read (class <object>) (class <object>) (class <object>))
    (assert eval (class <object>) (class <object>))
    (assert append (class <list>) (class <list>) (class <list>) 'repeat)
    (assert error (class <object>) (class <string>))
    (assertz error (class <object>) (class <string>) (class <object>))
    (assert string-append (class <string>) (class <string>) 'repeat)
    (assert symbol-function (class <function>) (class <symbol>))
    (assert apply (class <function>) (class <object>) 'repeat)
    (assert print (class <null>) (class <object>))
    (assert aref (class <object>) (class <general-array*>) (class <integer>) 'repeat)
    (assertz aref (class <object>) (class <general-vector>) (class <integer>))
    (assert garef (class <object>) (class <general-array*>) (class <integer>) 'repeat)
    (assert
     set-aref
     (class <null>)
     (class <object>)
     (class <general-array*>)
     (class <integer>)
     (class <integer>))
    (assert array-dimensions (class <list>) (class <general-array*>))
    (assert create-array (class <general-array*>) (class <list>))
    (assert equal (class <object>) (class <object>) (class <object>))
    (assert open (class <stream>) (class <string>))
    (assert close (class <null>) (class <object>))
    (assert standard-input (class <stream>))
    (assert standard-output (class <stream>))
    (assert create-string-input-stream (class <stream>))
    (assert create-string-output-stream (class <stream>))
    (assert get-output-stream-string (class <string>) (class <object>))
    (assert open-input-file (class <stream>))
    (assert open-output-file (class <stream>))
    (assert open-io-file (class <stream>))
    (assert finish-output (class <null>) (class <stream>))
    (assert ignore-toplevel-check (class <object>) (class <object>))
    (assert system (class <null>) (class <string>))
    (assert macroexpand-1 (class <list>) (class <list>))
    (assert get-method (class <object>) (class <object>))
    (assert get-method-body (class <object>) (class <object>))
    (assert get-method-priority (class <object>) (class <object>))
    (assert readed-array-list (class <object>) (class <object>))
    (assert class-of (class <object>) (class <object>))
    (assert subclassp (class <object>) (class <object>) (class <object>))
    (assert read-byte (class <object>) (class <stream>))
    (assert write-byte (class <null>) (class <object>) (class <stream>))
    (assert probe-file (class <object>) (class <string>))
    (assert file-position (class <integer>) (class <stream>))
    (assert set-file-position (class <integer>) (class <stream>) (class <integer>))
    (assert file-length (class <object>) (class <stream>) (class <integer>))
    (assert cerror (class <object>) (class <string>) (class <string>) (class <object>))
    (assert signal-condition (class <object>) (class <object>) (class <object>))
    (assert condition-continuable (class <object>) (class <object>))
    (assert continue-condition (class <object>) (class <object>))
    (assert arithmetic-error-operation (class <function>) (class <object>))
    (assert arithmetic-error-operands (class <list>) (class <object>))
    (assert domain-error-object (class <object>) (class <object>))
    (assert domain-error-expected-class (class <object>) (class <object>))
    (assert parse-error-string (class <string>) (class <object>))
    (assert parse-error-expected-class (class <object>) (class <object>))
    (assert simple-error-format-string (class <string>) (class <object>))
    (assert simple-error-format-arguments (class <list>) (class <object>))
    (assert stream-error-stream (class <stream>) (class <object>))
    (assert read-line (class <object>) (class <stream>))
    (assertz read-line (class <object>) (class <stream>) (class <object>))
    (assert random (class <integer>) (class <integer>))
    (assert random-real (class <float>))
    (assert eql (class <object>) (class <object>) (class <object>))
    (assert quotient (class <float>) (class <number>) (class <number>))
    (assert subrp (class <object>) (class <object>))
    (assert c-lang (class <null>) (class <string>))
)
