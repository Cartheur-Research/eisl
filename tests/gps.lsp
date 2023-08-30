;;; GPS(General problem Solver) PAIP
(defglobal *ops* nil)

;; solve a goal
(defun gps-one (goal state)
    (cond ((achieve goal state) state)
          (t (gps-one goal (apply-op goal state)))))

;; solve goals  
(defun gps (goals state)
    (if (null goals)
        state
        (let ((result (gps-one (car goals) state)))
            (if result
                (gps (cdr goals) result)
                nil))))

;; when goal is member of state, achieved a goal
(defun achieve (goal state)
    (if (member goal state) t nil))

;; apply goal on rule *ops*
(defun apply-op (goal state)
    (apply-op1 goal state *ops*))
    
;; sub program of apply
(defun apply-op1 (goal state ops)
    (cond ((null ops) nil) ;false 
          ((appropriate-p goal state (car ops)) ;success goal
           (format (standard-output) "executing ~A~%" (op-action (car ops)))
           (union (set-difference state (op-del-list (car ops))) (op-add-list (car ops))))
          (t (apply-op1 goal state (cdr ops))))) ; try next ops

;; case1 goal is member of add-list and state is subset of precond -> success
;; case2 goal is member of add-list and state is not subset of precond -> try subgoal precond.
;; case3 or else false
(defun appropriate-p (goal state op)
    (if (member goal (op-add-list op))
        (if (subsetp state (op-precond op))
            state
            (gps (op-precond op) state))
        nil))
          
(defun union (x y)
    (cond ((null x) y)
          ((member (car x) y) (union (cdr x) y))
          (t (cons (car x) (union (cdr x) y)))))

(defun set-difference (x y)
    (append (set-difference1 x y)
            (set-difference1 y x)))

(defun set-difference1 (x y)
    (cond ((null x) nil)
          ((member (car x) y) (set-difference1 (cdr x) y))
          (t (cons (car x) (set-difference1 (cdr x) y)))))

(defun subsetp (x y)
    (cond ((null x) t)
          ((member (car x) y) (subsetp (cdr x) y))
          (t nil)))

(defun make-op (action precond add-list del-list)
    (list action precond add-list del-list))

(defun op-action (x) (elt x 0))

(defun op-precond (x) (elt x 1))

(defun op-add-list (x) (elt x 2))

(defun op-del-list (x) (elt x 3))


;;; test
(defglobal *school-ops*
    (list
        (make-op 'drive-son-to-school
                 '(son-at-home car-works)
                 '(son-at-school)
                 '(son-at-home))
        (make-op 'shop-installs-battery
                 '(car-needs-battery shop-knows-problem shop-has-money)
                 '(car-works)
                 nil)
        (make-op 'tell-shop-problem
                 `(in-communication-with-shop)
                 '(shop-knows-problem)
                 nil)
        (make-op 'telephone-shop
                 '(know-phone-number)
                 '(in-communication-with-shop)
                 nil)
        (make-op 'look-up-number
                 '(have-phone-book)
                 '(know-phone-number)
                 nil)
        (make-op 'give-shop-money
                 '(have-money)
                 '(shop-has-money)
                 '(have-mone))))

(defun test1 ()
    (setq *ops* *school-ops*)
    (gps '(son-at-school)
         '(son-at-home car-needs-battery have-money have-phone-book)))
