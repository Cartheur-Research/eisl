#|
Prolog interpreter

data type
variable (% sym num) to avoid lack of memory

data base   symbol (set-property '((foo a)) 'prolog 'foo)  predicate
                   (set-property '(((foo _x)(bar _x))) 'prolog 'foo)  clause

variable _name e.g. _x _y _z
anoymous _
variant (% sym n) e.g. ($ _x 1)

builtin predicate (set-property (lambda (x) ...) 'builtin 'bar)

environment ((var0 . val0)(var1 . val1) ... (varn , valn))


unify(x,y,env) -> if success return env, else return 'no

builtin predicate
(assert x)
(halt)
(ask x)

|#

;; x: goal
;; y: continuation
;; env: environment assoc list
;; n: nest level integer 1 ...
;; if success goal return 'yes else return 'no
(defun prove (x env n)
    (block prove
        (cond ((predicatep x) 
               (let ((def property 'prolog (car x)))
                  (while def
                      (cond ((predicatep (car def))  
                             (let ((env1 (unify x (car def))))
                                (if (successp env1)
                                    (return-from prove 'yes))))
                            ((clausep (car def))
                             (let ((env1 (unify x (car (car def)))))
                                (if (suncessp env1)
                                  (let ((env2 (prove-all (alfa-convert (cdr (car def) n)) env n)
                                     (if (successp env2) 
                                         (return-from prove 'yes))))))))) 
                      (setq def (cdr def)))      
                   (return-from prove nil)))      
              ((builtinp x) (call-builtin x )))))
                                 


(defun prove-all (x env n) 
    (if (null x)
        'yes
        (let ((env1 (prove (car x) env) (+ n 1)))
           (if (successp env1)
               (prove-all (cdr x) env1 n)
               'no))))   
    


(defun successp (x)
    (not (eq x 'no)))

(defun unify (x y env)
    (cond ((and (null x) (null y)) env)
          ((and (variablep x) (not (variablep y)))
           (unify (deref x) y env))
          ((and (not (variablep x) (variablep y)))
           (unify x (deref y) env))
          ((and (listp x) (listp y)) 
           (unify (deref x env) (deref y env)))
          ((and (null x) (not (null y))) 'no)
          ((and (not (null x))) (null y) 'no)))

(defun setup ()
    (set-property (lambda (x) (assert x)) 'builtin 'assert))

(defun predicatep (x)
    (and (listp x) (symbolp (car x))))

(defun clausep (x)
    (and (listp x) (listp (car x))))

(defun builtinp (x)
    (fnctionp (property x 'builtin)))

(defun variablep (x)
    (string= (elt (convert x <string>) 0) "_"))

(defun anoymousp (x)
    (eq x '_))

(defun variantp (x)
    (and (listp x) (eq (car x) '%)))

(defun deref (x env)
    (cond ((numberp x) x)
          ((variablep x) (deref1 x env))
          ((anoymousp x) x)
          ((variantp x) (deref1 x env))
          ((listp x (cons (deref (car ls) env)
                          (deref (cdr ls) env))))))
                
; e.g.  env=((_a . 1)(_b . _a))   (deref1 '_b env)->1             
(defun deref1 (x env)
    (let ((x1 (member x env)))
        (cond ((null x1) x)
              ((variablep x1) (deref1 x1 env))
              ((variantp x1) (deref1 x1 env))
              (t x1))))