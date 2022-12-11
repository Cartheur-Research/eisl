(DEFMODULE GCD
           (DEFCONSTANT X 10)
           (DEFCONSTANT Y 45)
           (DEFGLOBAL Z NIL)
           (DEFUN GCD1
                  NIL
                  (LET ((A NIL) (B NIL))
                       (SETQ A X)
                       (SETQ B Y)
                       (WHILE (/= A B) (IF (< A B) (SETQ B (- B A)) (SETQ A (- A B))))
                       (SETQ Z A)))
           (GCD1)
           (FORMAT (STANDARD-OUTPUT) "~A" Z))