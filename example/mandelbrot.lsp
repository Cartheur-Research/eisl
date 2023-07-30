(import "plot")

(defun mandelbrot-draw ()
    (open-plot)
    (send-plot "set term png size 900, 900")
    (send-plot "set output \"mandelbrot.png\"")
    (send-plot "set grid")
    (send-plot "set pm3d map")
    (send-plot "set size square")
    (send-plot "set palette defined (0 \"#000000\", 2 \"#c00000\", 7 \"#ffff00\", 9 \"#ffffff\") ")
    (send-plot "splot \"data1.txt\" \"data2.exe.\"")
    (close-plot))



(defun mandelbrot-data ()
    (pexec (mandelbrot-part -1.0 -1.0 1.0 0.0 "data1.txt")
           (mandelbrot-part -1.0 0.0 1.0 1.0 "data2.txt")))

(defun mandelbrot-part (r1 i1 r2 i2 file)
    (let ((stream (open-output-file file)))
         (for ((r r1 (+ r 0.01)))
              ((> r r2) t)
              (for ((i i1 (+ i 0.01)))
                   ((> i i2) t)
                   (format stream "~G ~G ~G~%" r i (mandelbrot r i))))
         (close stream)))


(defun mandelbrot (a b)
    (mandelbrot1 0 0 a b 0))

(defun mandelbrot1 (r i a b n)
    (cond ((> n 30) 1.0)
          ((> (cabs r i) 2) (log n))
          (t (mandelbrot1 (+ (- (* r r) (* i i)) a)
                           (+ (* 2 r i) b)
                           a
                           b 
                           (+ n 1)))))


(defun cabs (r i)
    (sqrt (+ (* r r) (* i i))))
             

