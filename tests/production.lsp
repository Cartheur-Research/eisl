;; idea memo
;; production system 
;; C + O2  -> CO2
;; 2H2 + O2 -> 2H2O
;; C + 2H2 -> CH4
;; CH4 + 2O2 -> CO2 + 2H2O

;; extend defpattern to handle set 
(import "elixir")

(defpattern reaction 
    (((element _x C O2)) (print 'rule1) (reaction (modify _x '(- C) '(- O2) '(+ CO2))))
    (((element _x (2 H2) O2)) (print 'rule2) (reaction (modify _x '(- (2 H2))  '(- O2) '(+ (2 H2O)))))
    (((element _x C (2 H2))) (print 'rule3) (reaction (modify _x '(- C) '(- (2 H2)) '(+ CH4))))
    (((element _x CH4 (2 O2))) (print 'rule4) (reaction (modify _x '(- CH4) '(- (2 O2)) '(+ CO2) '(+ (2 H2O)))))
    ((_x) _x))

