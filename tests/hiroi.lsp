
;;; written by M.hiroi
;リスト : delay と force

(defmacro delay (expr)
    `(make-promise (lambda ()(,expr))) )

(defun make-promise (f)
    (let ((flag nil)
          (result nil) )
       (lambda ()
          (if (not flag)
              (let ((x (funcall f)))
                 (cond ((not flag) (setq flag t) (setq result x)))))
          result)))

(defun force (promise)
    (funcall promise) )
