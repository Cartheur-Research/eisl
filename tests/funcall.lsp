
    (defun comp-funcall-clang (stream x env args tail name global test clos)
        (let ((n (cdr (assoc (car x) function-arg))))
           (when (and (> n 0) (/= (length (cdr x)) n)) (error* "call: illegal arument count" x))
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
                         (format stream ");~%"))))
           (format stream "res = ")
           (format-object stream (conv-name (car x)) nil)
           (format stream "(")
           (comp-funcall-clang3 stream 1 (length (cdr x)))
           (format stream ");~%")
           (cond ((not (null (cdr x)))
                  (for ((ls (cdr x) (cdr ls))
                        (n (length (cdr x)) (- n 1)) )
                       ((null ls)
                         t )
                       (format stream "arg")
                       (format-integer stream n 10)
                       (format stream "=Fshelterpop();~%"))))
           (format stream ";res;})"))
    )

    (defun comp-funcall-clang3 (stream m n)
        (cond ((> m n) )
              ((= m n)
               (format stream "arg")
               (format-integer stream m 10))
              (t
               (format stream "arg")
               (format-integer stream m 10)
               (format stream ",")
               (comp-funcall-clang3 stream (+ m 1) n))))
