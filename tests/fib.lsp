(defun foo (x y)
  (append x y))

(defun fib* (n)
  (cond ((= n 1.0) 1.0)
        ((= n 2.0) 1.0)
        (t (+ (fib* (- n 1.0)) (fib* (- n 2.0))))))

(defun fib (n)
  (cond ((= n 1) 1)
        ((= n 2) 1)
        (t (+ (fib (- n 1)) (fib (- n 2))))))