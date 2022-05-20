;; test formula library for compiler

(div 100000000000000000000000000000000000000000000000 100000000000000000000000000)
1000000000000000000000000000000
1000000000000000000000
1000000000000000000000
(defun bar ()
    (QUOTIENT -300000000000000000000 -30000000000))

(import "formula")

(defun fib (n)
    (the <fixnum> n)
    (cond ((= n 1) 1)
          ((= n 2) 1)
          (t (+ (fib (- n 1)) (fib (- n 2)))) ))

(defun fib1 (n)
    (the <fixnum> n)
    (cond ((= n 1) 1)
          ((= n 2) 1)
          (t (formula (fib1 (n - 1)) + (fib1 (n - 2)))) ))


(defglobal a "こんにちは")

(defun foo ()
    (set-aref #\か a 0))


(defun fact (n)
    (if (= n 0)
        1
        (* n (fact (- n 1)))))






