(defmodule string
    
    (defpublic string-split (str x)
        (let ((x1 (car (convert x <list>))))
           (split1 (convert str <list>) x1 "") ))

    (defun split1 (ls x y)
        (cond ((null ls) (list y))
              ((char= (car ls) x) (cons y (split1 (cdr ls) x "")))
              (t (split1 (cdr ls) x (string-append y (create-string 1 (car ls)))))))

    (defpublic string-replace (str x y)
        (let ((x1 (car (convert x <list>)))
              (y1 (car (convert y <list>))) )
           (replace1 (convert str <list>) x1 y1)))

    (defun replace1 (ls x y)
        (cond ((null ls) "")
              ((char= (car ls) x) (string-append (create-string 1 y) (replace1 (cdr ls) x y)))
              (t (string-append (create-string 1 (car ls)) (replace1 (cdr ls) x y)))))

    (defpublic string-delete (str x)
        (let ((x1 (car (convert x <list>))))
           (delete1 (convert str <list>) x1)))

    (defun delete1 (ls x)
        (cond ((null ls) "")
              ((char= (car ls) x) (string-append (delete1 (cdr ls) x)))
              (t (string-append (create-string 1 (car ls)) (delete1 (cdr ls) x)))))

    (defpublic string-slice (str s e)
        (slice1 (convert str <list>) s e 0))

    (defun slice1 (ls s e i)
        (cond ((= i e) "")
              ((< i s) (slice1 (cdr ls) s e (+ i 1)))
              (t (string-append (create-string 1 (car ls)) (slice1 (cdr ls) s e (+ i 1))))))

    (defpublic string-remove (str s e)
        (remove1 (convert str <list>) s e 0))

    (defun remove1 (ls s e i)
        (cond ((null ls) "")
              ((and (>= i s) (< i e)) (remove1 (cdr ls) s e (+ i 1)))
              (t (string-append (create-string 1 (car ls)) (remove1 (cdr ls) s e (+ i 1))))))

    (defpublic string-reverse (str)
        (list-to-string1 (reverse (convert str <list>))))

    (defpublic list-to-string (ls)
        (list-to-string1 ls))

    (defun list-to-string1 (ls)
        (cond ((null ls) "")
              (t (string-append (create-string 1 (car ls)) (list-to-string1 (cdr ls))))))

    (defpublic string-upper (str)
        (to-upper1 (convert str <list>)))

    (defun to-upper1 (ls)
        (cond ((null ls) "")
              (t
               (let ((ascii (convert (car ls) <integer>)))
                  (if (and (>= ascii 97) (<= ascii 122))
                      (string-append (create-string 1 (convert (- ascii 32) <character>))
                                     (to-upper1 (cdr ls)))
                      (string-append (create-string 1 (car ls)) (to-upper1 (cdr ls))))))))

    (defpublic string-lower (str)
        (to-lower1 (convert str <list>)))

    (defun to-lower1 (ls)
        (cond ((null ls) "")
              (t
               (let ((ascii (convert (car ls) <integer>)))
                  (if (and (>= ascii 65) (<= ascii 90))
                      (string-append (create-string 1 (convert (+ ascii 32) <character>))
                                     (to-lower1 (cdr ls)))
                      (string-append (create-string 1 (car ls)) (to-lower1 (cdr ls))))))))

    (defpublic string-head (str)
        (create-string 1 (elt str 0)))

    (defpublic string-tail (str)
        (create-string 1 (car (reverse (convert str <list>)))))

    (defpublic string-null-p (str)
        (and (stringp str) (string= str "")))

    (defpublic digit-char-p (c)
        (if (characterp c)
            (let ((ascii (convert c <integer>)))
               (and (>= ascii 48) (<= ascii 57)))
            nil))

    (defpublic alpha-char-p (c)
        (if (characterp c)
            (let ((ascii (convert c <integer>)))
               (or (and (>= ascii 65) (<= ascii 90))
                   (and (>= ascii 97) (<= ascii 122))))
            nil))

    ;;; TO-STRING converts a given non-sequence atom to a string value
    (defpublic to-string (x)
        (to-string1 x))

    (defgeneric to-string1 (value))

    (defmethod to-string1 ((value <character>)) (create-string 1 value))
    (defmethod to-string1 (value) (convert value <string>))
    ;;; JOIN concatenates together a sequence of strings into a single string with the joiner string separating each element string.
    ;;; Comparable to .join() in Python or Javascript 
    ;;; ELEMENTS is a sequence of strings to be joined
    ;;; JOINER is a string that will be concatenated between the element strings
    (defpublic join (x y)
        (join1 x y))

    (defgeneric join1 (elements joiner))

    (defmethod join1
               ((elements <list>) (joining-string <string>))
               (let ((joined-string (car elements))
                     (remaining-elements (cdr elements)) )
                  (while (consp remaining-elements)
                     (setf joined-string
                           (string-append joined-string joining-string (car remaining-elements)))
                     (setf remaining-elements (cdr remaining-elements)))
                  joined-string))
    (defmethod join1
               ((elements <general-vector>) (joining-string <string>))
               (join1 (convert elements <list>) joining-string))
    (defmethod join1
               (elements (joining-char <character>))
               (join1 elements (to-string joining-char)))
    
)
