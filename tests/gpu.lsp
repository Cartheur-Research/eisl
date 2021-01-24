
(defglobal a #2f((1.0 2.0 3.0)(4.0 5.0 6.0)))

(defglobal b #2f((4.0 7.0)(5.0 8.0)(6.0 9.0)))

(defun foo ()
    (print (gpu-mult a b))
    (print (gpu-add b b))
    (print (gpu-sub b b))
    (print (gpu-smult 2.0 a)))

(defglobal c (create-array '(30 30) 'rand 'float))

(defun test1 (n)
    (for ((i 0 (+ i 1)))
         ((> i n) t)
         (gpu-mult c c)))

(defglobal d (create-array '(3000 3000) 'rand 'float))

(defun test2 ()
    (gpu-mult d d))