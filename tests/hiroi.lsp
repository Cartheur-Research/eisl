;　クイックソート
; written by M.hiroi

(defun quick-sort (xs)
    (if (null xs)
        nil
        (let ((zs (partition (lambda (x) (> x (car xs))) (cdr xs))))
           (append (quick-sort (car zs)) (cons (car xs) (quick-sort (cdr zs)))) )))

(defun partition (pred xs)
    (for ((xs xs (cdr xs))
          (ys nil)
          (zs nil) )
         ((null xs)
          (cons (nreverse ys) (nreverse zs)) )
         (if (funcall pred (car xs))
             (setq ys (cons (car xs) ys))
             (setq zs (cons (car xs) zs)) )))
