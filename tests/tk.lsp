;; test tcltk library

(compile-file "library/tcltk.lsp") ;; re compile
(import "tcltk")

(defun main ()
  (tk::init)
  (tk::label 'hello '-text "hello world" '-width 50 '-height 15)
  (tk::button 'bt1 '-text "button1")
  (tk::button 'bt2 '-text "button2")
  (tk::radiobutton 'rbt1 '-text '(one 1))
  (tk::radiobutton 'rbt2 '-text '(two 2))
  (tk::pack 'hello 'bt1 'bt2 'rbt1 'rbt2)
  (tk::mainloop)
  T)


(defun canvas ()
  (tk::init)
  (tk::canvas 'c0)
  (for ((i 10 (+ i 10)))
       ((> i 200) t)
       (tk::create 'c0 (rectangle i i (+ i 10) (+ i 10) '-fill 'red)))
  (tk::pack 'c0)
  (tk::mainloop))
