;;; stat

(defmodule stat
    (import "sort" quick-sort)
    
    (defpublic mean (ls)
        (quotient (apply #'+ ls) (length ls)) )

    (defpublic median (ls)
        (let* ((n (length ls))
               (m (div n 2))
               (ls1 (quick-sort ls)) )
            (if (oddp n)
                (elt ls1 m)
                (mean (list (elt ls (- m 1)) (elt ls m))))))

    (defpublic mode (ls)
        (let ((ls1 (pack (quick-sort ls))))
           (mode1 (cdr ls1) (car ls1))))

    (defun mode1 (ls x)
        (cond ((null ls) (car x))
              ((> (length (car ls)) (length x)) (mode1 (cdr ls) (car ls)))
              (t (mode1 (cdr ls) x))))

    (defun oddp (n)
        (= (mod n 2) 1))

    (defun pack (x)
        (let ((y (pack1 (car x) '() x)))
           (if (null (cdr y))
               y
               (cons (car y) (pack (cdr y))))))

    (defun pack1 (x y z)
        (cond ((null z) (cons y nil))
              ((not (eq x (car z))) (cons y z))
              (t (pack1 x (cons (car z) y) (cdr z)))))


    (defpublic variance (ls)
        (let ((x1 (mean ls)))
            (mean (mapcar (lambda (x) (square (- x x1))) ls))))
    
    (defun square (x)
        (* x x))
    
    ;;standard deviation, SD
    (defpublic sd (ls)
        (sqrt (variance ls)))


    (defpublic minimum (ls)
        (minimum1 ls *most-positive-float*))
    
    (defun minimum1 (ls x)
        (cond ((null ls) x) 
              ((< (car ls) x) (minimum1 (cdr ls) (car ls)))
              (t (minimum1 (cdr ls) x))))

    (defpublic maximum (ls)
        (maximum1 ls *most-negative-float*))
    
    (defun maximum1 (ls x)
        (cond ((null ls) x) 
              ((> (car ls) x) (maximum1 (cdr ls) (car ls)))
              (t (maximum1 (cdr ls) x))))

    (defpublic standardize (ls)
        (let ((x1 (mean ls))
              (s (sd ls)))
            (mapcar (lambda (x) (quotient (- x x1) s)) ls)))

)
