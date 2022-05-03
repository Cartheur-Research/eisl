(defmacro when (test :rest body)
    `(if ,test (progn ,@body)) )

(defmacro unless (test :rest body)
    `(if (not ,test) (progn ,@body)) )

(defglobal *e* 2.718281828459045)
(defglobal *gamma* 0.57721566490153286060)

(defun oddp (n)
    (and (integerp n) (= (mod n 2) 1)) )

(defun evenp (n)
    (and (integerp n) (= (mod n 2) 0)) )

(defun zerop (n)
    (= n 0) )

(defun square (n)
    (* n n) )

(defun set-aref1 (val mat i j)
    (set-aref val mat (- i 1) (- j 1)) )

(defun aref1 (mat i j)
    (aref mat (- i 1) (- j 1)) )

(defun mult-scalar-mat (s mat)
    (let ((m (elt (array-dimensions mat) 0))
          (n (elt (array-dimensions mat) 1)) )
       (for ((i 1 (+ i 1)))
            ((> i m)
             mat )
            (for ((j 1 (+ j 1)))
                 ((> j n))
                 (set-aref1 (* s (aref1 mat i j)) mat i j)))))

(defun matrix-ident (n)
    (let ((m (create-array (list n n) 0)))
       (for ((i 1 (+ i 1)))
            ((> i n)
             m )
            (set-aref1 1 m i i))))

(defun square-matrix-p (x)
    (let ((dim (array-dimensions x)))
       (and (= (length dim) 2) (= (elt dim 0) (elt dim 1))) ))

(defun tr (x)
    (unless (square-matrix-p x) (error "tr require square matrix" x))
    (let ((l (elt (array-dimensions x) 0)))
       (for ((i 1 (+ i 1))
             (y 0) )
            ((> i l)
             y )
            (setq y (+ (aref1 x i i) y)))))


(defun sub-matrix (x r s)
    (let* ((m (elt (array-dimensions x) 0))
           (n (elt (array-dimensions x) 1))
           (y (create-array (- m 1) (- n 1) 0)) )
        (for ((i 0 (+ i 1)))
             ((>= i m)
              y )
             (for ((j 0 (+ j 1)))
                  ((>= j n))
                  (cond ((and (< i r) (< j s)) (set-aref1 (aref1 x i j) y i j))
                        ((and (> i r) (< j s)) (set-aref1 (aref1 x i j) y (- i 1) j))
                        ((and (< i r) (> j s)) (set-aref1 (aref1 x i j) y i (- j 1)))
                        ((and (> i r) (> j s)) (set-aref1 (aref1 x i j) y (- i 1) (- j 1)))
                        ((and (= i r) (= j s)) nil))))))

(defun det (x)
    (unless (square-matrix-p x) (error "det require square matrix" x))
    (let ((m (elt (array-dimensions x) 0)))
       (det1 x m) ))



(defun det1 (x m)
    (if (= m 2)
        (- (* (aref1 x 1 1) (aref1 x 2 2))
           (* (aref1 x 1 2) (aref1 x 2 1)))
        (for ((i 1 (+ i 1))
              (y 0) )
             ((> i m)
              y )
             (setq y (+ (* (sign (+ i 1)) (aref1 x i 1) (det1 (sub-matrix x i 1) (- m 1))) y)))))

(defun sign (x)
    (expt -1 x) )

(defun transpose (x)
    (let* ((m (elt (array-dimensions x) 0))
           (n (elt (array-dimensions x) 1))
           (y (create-array (list n m) 0)) )
        (for ((i 1 (+ i 1)))
             ((> i m)
              y )
             (for ((j 1 (+ j 1)))
                  ((> j n))
                  (set-aref1 (aref1 x i j) y j i)))))


(defun inv (x)
    (unless (square-matrix-p x) (error "inv require square matrix" x))
    (let ((m (elt (array-dimensions x) 0))
          (n (elt (array-dimensions x) 1)) )
       (if (> m 2)
           (inv1 x m)
           (inv0 x m))))

(defun inv0 (x m)
    (let ((mat (create-array (list m m) 0))
          (d (det x)) )
       (when (= d 0) (error "inv determinant is zero" x))
       (cond ((= m 1) (set-aref1 (quotient 1 d) mat 1 1) mat)
             (t
              (set-aref1 (aref1 x 2 2) mat 1 1)
              (set-aref1 (aref1 x 1 1) mat 2 2)
              (set-aref1 (- (aref1 x 1 2)) mat 1 2)
              (set-aref1 (- (aref1 x 2 1)) mat 2 1)
              (mult-scalar-mat (quotient 1 d) mat)))))

(defun inv1 (x m)
    (let ((d (det x)))
       (when (= d 0) (error "inv determinant is zero" x))
       (* (quotient 1 d) (transpose (inv2 x m))) ))

(defun inv2 (x m)
    (let ((y (create-array (list m m) 0)))
       (for ((i 1 (+ i 1)))
            ((> i m)
             y )
            (for ((j 1 (+ j 1)))
                 ((> j m))
                 (set-aref1 y i j (* (sign (+ i j)) (det (sub-matrix x i j))))))))


(defun sum (f ls)
    (if (null ls)
        0
        (+ (funcall f (car ls))
           (sum f (cdr ls)))))


(defun product (f ls)
    (if (null ls)
        1
        (* (funcall f (car ls))
           (product f (cdr ls)))))


(defun for-all (f ls)
    (cond ((null ls) t)
          ((not (funcall f (car ls))) nil)
          (t (for-all f (cdr ls))) ))

(defun at-least (f ls)
    (cond ((null ls) nil)
          ((funcall f (car ls)) t)
          (t (at-least f (cdr ls))) ))

(defun gauss-primes (x)
    (quotient x (log x)) )



(defun coprimep (m n)
    (= (gcd m n) 1) )

(defun divisiblep (m n)
    (and (integerp m) (integerp n) (= (mod m n) 0)) )

(defun eqmodp (m n a)
    (= (mod m a) (mod n a)) )

(defun primep (n)
    (if (< n 100000000000)
        (deterministic-prime-p n)
        (rabin-miller-p n) ))

(defun deterministic-prime-p (n)
    (labels ((iter (x y)
               (cond ((> x y) t)
                     ((divisiblep n x) nil)
                     ((= x 2) (iter 3 y))
                     (t (iter (+ x 2) y)) )))
        (if (< n 2)
            nil
            (iter 2 (sqrt n)))))

(defun prime (n)
    (elt *prime-list* (- n 1)))

(defun primepi (n)
    (labels ((iter (x y)
               (cond ((> x n) y)
                     ((primep x) (iter (+ x 1) (+ y 1)))
                     (t (iter (+ x 1) y)) )))
        (iter 2 0)))

(defun tau (n)
    (labels ((iter (ls m)
               (if (null ls)
                   m
                   (iter (cdr ls) (* (+ (elt (elt ls 0) 1) 1) m)) )))
        (if (= n 1)
            1
            (iter (factorize n) 1))))

(defun expt-1 (n)
    (if (oddp n)
        -1
        1 ))

(defun liouville-lambda (n)
    (expt-1 (omega n)) )

(defun omega (n)
    (if (= n 1)
        0
        (sum (lambda (x)(((elt x 1)))) (factorize n)) ))



(defun g (n)
    (sum #'liouville-lambda (divisors n)) )


(defun sigma2 (ls)
    (let ((p (elt ls 0))
          (k (elt ls 1)) )
       (quotient (- (expt p (+ k 1)) 1) (- p 1))))

(defun sigma (n)
    (cond ((< n 1) nil)
          ((= n 1) 1)
          (t (product #'sigma2 (factorize n))) ))


(defun perfectp (n)
    (= (sigma n) (* 2 n)) )

;;2^p -1
(defun mersenne (p)
    (- (expt 2 p) 1) )

(defun double-perfect-number-p (n)
    (= (sigma n) (* 3 n)) )

(defun find-double-perfect (n)
    (labels ((iter (m ls)
               (cond ((> m n) ls)
                     ((double-perfect-number-p m) (iter (+ m 1) (cons m ls)))
                     (t (iter (+ m 1) ls)) )))
        (iter 1 '())))


(defun fermatp (n)
    (labels ((iter (m)
               (cond ((< m 1) t)
                     ((not (= 1 (gaussmod (+ (random (- n 2)) 1) (- n 1) n))) nil)
                     (t (iter (- m 1))) )))
        (iter 10)))

(defun lucasp (p)
    (labels ((iter (n i m)
               (cond ((and (= i (- p 1)) (zerop (mod n m))) t)
                     ((and (= i (- p 1)) (not (zerop (mod n m)))) nil)
                     (t (iter (mod (- (expt n 2) 2) m) (+ i 1) m)) )))
        (cond ((< p 2) nil)
              ((= p 2) t)
              (t (iter 4 1 (mersenne p))))))

(defun fermat-number (n)
    (+ (expt 2 (expt 2 n)) 1) )

(defun rm1 (n)
    (labels ((iter (k q)
               (if (oddp q)
                   (list k q)
                   (iter (+ k 1) (div q 2)) )))
        (iter 0 (- n 1))))

(defun rm2 (a q n)
    (not (= (gaussmod a q n) 1)) )

(defun rm3 (a k q n)
    (labels ((iter (i)
               (cond ((>= i k) t)
                     ((= (gaussmod a (* (expt 2 i) q) n) -1) nil)
                     (t (iter (+ i 1))) )))
        (iter 0)))

(defun rm4 (n a)
    (let* ((ls (rm1 n))
           (k (elt ls 0))
           (q (elt ls 1)) )
        (and (rm2 a q n) (rm3 a k q n))))

(defun rabin-miller-p (n)
    (labels ((iter (m)
               (cond ((< m 1) nil)
                     ((rm4 n (+ (random (min (- n 2) 32767)) 1)) t)
                     (t (iter (- m 1))) )))
        (if (= n 2)
            t
            (not (iter 10)))))



(defun gaussmod (a k m)
    (let ((k1 (expmod a k m)))
       (cond ((and (> k1 0) (> k1 (quotient m 2)) (< k1 m)) (- k1 m))
             ((and (< k1 0) (< k1 (- (quotient m 2))) (> k1 (- m))) (+ k1 m))
             (t k1) )))

(defun twin-primes (n m)
    (labels ((iter (i j ls)
               (cond ((> i j) (reverse ls))
                     ((and (primep i) (primep (+ i 2)))
                      (iter (+ i 2) j (cons (list i (+ i 2)) ls)))
                     (t (iter (+ i 2) j ls)))))
        (cond ((<= n 2) (iter 3 (+ n m) '()))
              ((evenp n) (iter (+ n 1) (+ n m) '()))
              (t (iter n (+ n m) '())))))



(defun divisors (n)
    (labels ((iter (m o ls)
               (cond ((> m o) ls)
                     ((divisiblep n m) (iter (+ m 1) o (cons m ls)))
                     (t (iter (+ m 1) o ls)) )))
        (cond ((not (integerp n)) (error "divisors require natural number" n))
              ((< n 1) (error "divisors require natural number" n))
              ((= n 1) '(1))
              (t (cons n (iter 1 (ceiling (quotient n 2)) '()))))))


(defun prime-factors (n)
    (labels ((iter (p x ls z)
               (cond ((> p z) (cons x ls))
                     ((= (mod x p) 0) (let ((n1 (div x p)))
                                         (iter 2 n1 (cons p ls) (isqrt n1)) ))
                     ((= p 2) (iter 3 x ls z))
                     (t (iter (+ p 2) x ls z)))))
        (cond ((< n 0) nil)
              ((< n 2) (list n))
              (t (iter 2 n '() (isqrt n))))))

;;p^a + q^b + r^c ((p a)(q b)(r c))
(defun factorize (n)
    (labels ((iter (ls p n mult)
               (cond ((null ls) (cons (list p n) mult))
                     ((= (car ls) p) (iter (cdr ls) p (+ n 1) mult))
                     (t (iter (cdr ls) (car ls) 1 (cons (list p n) mult))) )))
        (let ((ls (prime-factors n)))
           (iter (cdr ls) (car ls) 1 '()))))

;;(n=p^a q^b r^c) = n(1-1/p)(1-1/q)(1-1/r)
(defun phi (n)
    (if (= n 1)
        1
        (convert
         (* n (product (lambda (ls)
                          (- 1 (quotient 1 (elt ls 0)))) (factorize n)))
         <integer>)))


(defun primitive-root-p (n p)
    (labels ((iter (i)
               (cond ((>= i (- p 1)) t)
                     ((= (expmod n i p) 1) nil)
                     (t (iter (+ i 1))) )))
        (and (iter 1) (= (expmod n (- p 1) p) 1))))

;;sicp
;; a^n (mod m)
(defun expmod (a n m)
    (cond ((= 0 n) 1)
          ((evenp n) (mod (square (expmod a (div n 2) m)) m))
          (t (mod (* a (expmod a (- n 1) m)) m)) ))


(defun primitive-root (p)
    (labels ((iter (n)
               (cond ((> n p) nil)
                     ((primitive-root-p n p) n)
                     (t (iter (+ n 1))) )))
        (iter 2)))


(defun ind (r a p)
    (labels ((iter (i)
               (cond ((> i p) nil)
                     ((= (expmod r i p) a) i)
                     (t (iter (+ i 1))) )))
        (iter 0)))



;;
(defun highly-composite-number-p (n)
    (cond ((<= n 0) nil)
          ((= n 1) t)
          (t (> (tau n) (max-tau (- n 1) 0))) ))

(defun max-tau (n m)
    (let ((x (tau n)))
       (cond ((= n 1) m)
             ((> x m) (max-tau (- n 1) x))
             (t (max-tau (- n 1) m)) )))


;;prime list prime(N) N <= 1229

(defglobal *prime-list* 
    '(2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 107 109
      113 127 131 137 139 149 151 157 163 167 173 179 181 191 193 197 199 211 223 227 229 233 239 
      241 251 257 263 269 271 277 281 283 293 307 311 313 317 331 337 347 349 353 359 367 373 379 
      383 389 397 401 409 419 421 431 433 439 443 449 457 461 463 467 479 487 491 499 503 509 521 
      523 541 547 557 563 569 571 577 587 593 599 601 607 613 617 619 631 641 643 647 653 659 661 
      673 677 683 691 701 709 719 727 733 739 743 751 757 761 769 773 787 797 809 811 821 823 827 
      829 839 853 857 859 863 877 881 883 887 907 911 919 929 937 941 947 953 967 971 977 983 991 
      997 1009 1013 1019 1021 1031 1033 1039 1049 1051 1061 1063 1069 1087 1091 1093 1097 1103 1109 1117 
      1123 1129 1151 1153 1163 1171 1181 1187 1193 1201 1213 1217 1223 1229 1231 1237 1249 1259 1277 1279 
      1283 1289 1291 1297 1301 1303 1307 1319 1321 1327 1361 1367 1373 1381 1399 1409 1423 1427 1429 1433 
      1439 1447 1451 1453 1459 1471 1481 1483 1487 1489 1493 1499 1511 1523 1531 1543 1549 1553 1559 1567 
      1571 1579 1583 1597 1601 1607 1609 1613 1619 1621 1627 1637 1657 1663 1667 1669 1693 1697 1699 1709 
      1721 1723 1733 1741 1747 1753 1759 1777 1783 1787 1789 1801 1811 1823 1831 1847 1861 1867 1871 1873 
      1877 1879 1889 1901 1907 1913 1931 1933 1949 1951 1973 1979 1987 1993 1997 1999 2003 2011 2017 2027 
      2029 2039 2053 2063 2069 2081 2083 2087 2089 2099 2111 2113 2129 2131 2137 2141 2143 2153 2161 2179 
      2203 2207 2213 2221 2237 2239 2243 2251 2267 2269 2273 2281 2287 2293 2297 2309 2311 2333 2339 2341 
      2347 2351 2357 2371 2377 2381 2383 2389 2393 2399 2411 2417 2423 2437 2441 2447 2459 2467 2473 2477 
      2503 2521 2531 2539 2543 2549 2551 2557 2579 2591 2593 2609 2617 2621 2633 2647 2657 2659 2663 2671 
      2677 2683 2687 2689 2693 2699 2707 2711 2713 2719 2729 2731 2741 2749 2753 2767 2777 2789 2791 2797 
      2801 2803 2819 2833 2837 2843 2851 2857 2861 2879 2887 2897 2903 2909 2917 2927 2939 2953 2957 2963 
      2969 2971 2999 3001 3011 3019 3023 3037 3041 3049 3061 3067 3079 3083 3089 3109 3119 3121 3137 3163 
      3167 3169 3181 3187 3191 3203 3209 3217 3221 3229 3251 3253 3257 3259 3271 3299 3301 3307 3313 3319 
      3323 3329 3331 3343 3347 3359 3361 3371 3373 3389 3391 3407 3413 3433 3449 3457 3461 3463 3467 3469 
      3491 3499 3511 3517 3527 3529 3533 3539 3541 3547 3557 3559 3571 3581 3583 3593 3607 3613 3617 3623 
      3631 3637 3643 3659 3671 3673 3677 3691 3697 3701 3709 3719 3727 3733 3739 3761 3767 3769 3779 3793 
      3797 3803 3821 3823 3833 3847 3851 3853 3863 3877 3881 3889 3907 3911 3917 3919 3923 3929 3931 3943 
      3947 3967 3989 4001 4003 4007 4013 4019 4021 4027 4049 4051 4057 4073 4079 4091 4093 4099 4111 4127 
      4129 4133 4139 4153 4157 4159 4177 4201 4211 4217 4219 4229 4231 4241 4243 4253 4259 4261 4271 4273 
      4283 4289 4297 4327 4337 4339 4349 4357 4363 4373 4391 4397 4409 4421 4423 4441 4447 4451 4457 4463 
      4481 4483 4493 4507 4513 4517 4519 4523 4547 4549 4561 4567 4583 4591 4597 4603 4621 4637 4639 4643 
      4649 4651 4657 4663 4673 4679 4691 4703 4721 4723 4729 4733 4751 4759 4783 4787 4789 4793 4799 4801 
      4813 4817 4831 4861 4871 4877 4889 4903 4909 4919 4931 4933 4937 4943 4951 4957 4967 4969 4973 4987 
      4993 4999 5003 5009 5011 5021 5023 5039 5051 5059 5077 5081 5087 5099 5101 5107 5113 5119 5147 5153 
      5167 5171 5179 5189 5197 5209 5227 5231 5233 5237 5261 5273 5279 5281 5297 5303 5309 5323 5333 5347 
      5351 5381 5387 5393 5399 5407 5413 5417 5419 5431 5437 5441 5443 5449 5471 5477 5479 5483 5501 5503 
      5507 5519 5521 5527 5531 5557 5563 5569 5573 5581 5591 5623 5639 5641 5647 5651 5653 5657 5659 5669 
      5683 5689 5693 5701 5711 5717 5737 5741 5743 5749 5779 5783 5791 5801 5807 5813 5821 5827 5839 5843 
      5849 5851 5857 5861 5867 5869 5879 5881 5897 5903 5923 5927 5939 5953 5981 5987 6007 6011 6029 6037 
      6043 6047 6053 6067 6073 6079 6089 6091 6101 6113 6121 6131 6133 6143 6151 6163 6173 6197 6199 6203 
      6211 6217 6221 6229 6247 6257 6263 6269 6271 6277 6287 6299 6301 6311 6317 6323 6329 6337 6343 6353 
      6359 6361 6367 6373 6379 6389 6397 6421 6427 6449 6451 6469 6473 6481 6491 6521 6529 6547 6551 6553 
      6563 6569 6571 6577 6581 6599 6607 6619 6637 6653 6659 6661 6673 6679 6689 6691 6701 6703 6709 6719 
      6733 6737 6761 6763 6779 6781 6791 6793 6803 6823 6827 6829 6833 6841 6857 6863 6869 6871 6883 6899 
      6907 6911 6917 6947 6949 6959 6961 6967 6971 6977 6983 6991 6997 7001 7013 7019 7027 7039 7043 7057 
      7069 7079 7103 7109 7121 7127 7129 7151 7159 7177 7187 7193 7207 7211 7213 7219 7229 7237 7243 7247 
      7253 7283 7297 7307 7309 7321 7331 7333 7349 7351 7369 7393 7411 7417 7433 7451 7457 7459 7477 7481 
      7487 7489 7499 7507 7517 7523 7529 7537 7541 7547 7549 7559 7561 7573 7577 7583 7589 7591 7603 7607 
      7621 7639 7643 7649 7669 7673 7681 7687 7691 7699 7703 7717 7723 7727 7741 7753 7757 7759 7789 7793 
      7817 7823 7829 7841 7853 7867 7873 7877 7879 7883 7901 7907 7919 7927 7933 7937 7949 7951 7963 7993 
      8009 8011 8017 8039 8053 8059 8069 8081 8087 8089 8093 8101 8111 8117 8123 8147 8161 8167 8171 8179 
      8191 8209 8219 8221 8231 8233 8237 8243 8263 8269 8273 8287 8291 8293 8297 8311 8317 8329 8353 8363 
      8369 8377 8387 8389 8419 8423 8429 8431 8443 8447 8461 8467 8501 8513 8521 8527 8537 8539 8543 8563 
      8573 8581 8597 8599 8609 8623 8627 8629 8641 8647 8663 8669 8677 8681 8689 8693 8699 8707 8713 8719 
      8731 8737 8741 8747 8753 8761 8779 8783 8803 8807 8819 8821 8831 8837 8839 8849 8861 8863 8867 8887 
      8893 8923 8929 8933 8941 8951 8963 8969 8971 8999 9001 9007 9011 9013 9029 9041 9043 9049 9059 9067 
      9091 9103 9109 9127 9133 9137 9151 9157 9161 9173 9181 9187 9199 9203 9209 9221 9227 9239 9241 9257 
      9277 9281 9283 9293 9311 9319 9323 9337 9341 9343 9349 9371 9377 9391 9397 9403 9413 9419 9421 9431 
      9433 9437 9439 9461 9463 9467 9473 9479 9491 9497 9511 9521 9533 9539 9547 9551 9587 9601 9613 9619 
      9623 9629 9631 9643 9649 9661 9677 9679 9689 9697 9719 9721 9733 9739 9743 9749 9767 9769 9781 9787 
      9791 9803 9811 9817 9829 9833 9839 9851 9857 9859 9871 9883 9887 9901 9907 9923 9929 9931 9941 9949 
      9967 9973))
