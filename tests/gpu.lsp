(defmacro test (form1 form2 :rest pred)
    (if (null pred)
        `(if
          (equal ,form1 ',form2)
          (format (standard-output) "" ',form1)
          (format (standard-output) "~S is bad~%" ',form1))
        `(if
          (,@pred ,form1 ',form2)
          (format (standard-output) "" ',form1)
          (format (standard-output) "~S is bad~%" ',form1))))


(defglobal a #2f((1.0 2.0 3.0) (4.0 5.0 6.0)))
(defglobal b #2f((4.0 7.0) (5.0 8.0) (6.0 9.0)))
(defglobal c #2f((2.0 3.0) (4.0 5.0) (6.0 7.0)))
(test (gpu-mult a b) #2f((32.0 50.0) (77.0 122.0)))
(test (gpu-add b b) #2f((8.0 14.0) (10.0 16.0) (12.0 18.0)))
(test (gpu-sub b b) #2f((0.0 0.0) (0.0 0.0) (0.0 0.0)))
(test (gpu-smult 2.0 a) #2f((2.0 4.0 6.0) (8.0 10.0 12.0)))
(test (gpu-emult b c) #2f((8.0 21.0) (20.0 40.0) (36.0 63.0)))
(test (array-dimensions c) (3 2))

(defglobal z (create-array '(3000 3000) 'rand 'float))

(defun test1 ()
    (gpu-mult z z) )

(defun test2 (n)
  (for ((i n (- i 1)))
       ((< i 0) t)
       (test1)))

(defglobal m #2f((1.0 2.0) (3.0 4.0)))
(defglobal m1 #2f((1.0 -2.0 3.0) (4.0 5.0 -6.0)))
(defglobal m2 #2f((1010.0 1000.0 990.0) (1010.0 1000.0 990.0)))
(defglobal m4 #2f((1.0 2.0 3.0) (2.0 3.0 1.2)))
(defglobal m5 #2f((1.1 2.9 2.0) (2.2 3.1 1.2)))
(defglobal m6 #2f((0.1 0.9 0.1) (0.2 0.1 1.2)))
(defglobal t1 #2f((((1.0 2.0 3.0) (4.0 5.0 6.0) (7.0 8.0 9.0)))))
(defglobal f1 #2f((((1.0 2.0) (3.0 4.0)))))
(defglobal t2 #2f((((2.0 3.0) (4.0 5.0)))))
(defglobal t3 #2f((((1.0 2.0 3.0 3.3) (7.0 4.0 5.0 6.0) (1.1 7.0 8.0 9.0) (1.2 1.3 1.4 1.0)))))
(defglobal t4 #2f((((0.1 0.2) (0.3 0.4)))))
(defglobal t5 #2f((1.0 2.0 3.0 3.3 7.0 4.0 5.0 6.0 1.1 7.0 8.0 9.0 1.2 1.3 1.4 1.0)))

(test (gpu-emult m1 m1) #2f((1.0 4.0 9.0) (16.0 25.0 36.0)))
(test (gpu-sum m) 10.0)
(test (gpu-trace m) 5.0)
(test (gpu-ident 3) #2f((1.0 0.0 0.0) (0.0 1.0 0.0) (0.0 0.0 1.0)))
(test (gpu-transpose m1) #2f((1.0 4.0) (-2.0 5.0) (3.0 -6.0)))
(test (gpu-activate m2 'softmax)
#2f((0.9900544881820679 4.494840686675161e-05 2.040654534241071e-09) (0.9900544881820679 4.494840686675161e-05 2.040654534241071e-09)))
(test (gpu-loss m4 m5 'square) 0.4675000309944153)
(test (gpu-loss m4 m5 'cross) -4.678380012512207)
(test (gpu-activate m6 'sigmoid)
#2f((0.5249791741371155 0.7109494805335999 0.5249791741371155) (0.5498339533805847 0.5249791741371155 0.7685248255729675)))
(test (gpu-activate m6 'tanh)
#2f((0.09966800361871719 0.7162978649139404 0.09966800361871719) (0.1973753273487091 0.09966800361871719 0.8336546421051025)))
(test (gpu-activate m6 'relu)
#2f((0.1000000014901161 0.8999999761581421 0.1000000014901161) (0.2000000029802322 0.1000000014901161 1.200000047683716)))
(test (gpu-average m6)
#2f((0.1500000059604645 0.5 0.6500000357627869)))
(test (gpu-convolute t1 f1 '(1 1) 0)
#4f((((37.0 47.0) (67.0 77.0)))))
(test (gpu-deconvolute t2 f1 '(1 1) 0)
#4f((((2.0 7.0 6.0) (10.0 30.0 22.0) (12.0 31.0 20.0)))))
(test (gpu-gradfilter t1 f1 t2 '(1 1) 0)
#4f((((49.0 63.0) (91.0 105.0)))))
(test (gpu-pooling t3 '(2 2))
(#4f((((7.0 6.0) (7.0 9.0)))) #4f((((1000.0 1003.0) (2001.0 2003.0))))))
(defglobal b (elt (gpu-pooling t3 '(2 2)) 1))
(test (gpu-unpooling b t4 '(2 2))
#4f((((0.0 0.0 0.0 0.0) (0.1000000014901161 0.0 0.0 0.2000000029802322) (0.0 0.300000011920929 0.0 0.4000000059604645) (0.0 0.0 0.0 0.0)))))
(test (gpu-full t3)
#2f((1.0 2.0 3.0 3.299999952316284 7.0 4.0 5.0 6.0 1.100000023841858 7.0 8.0 9.0 1.200000047683716
 1.299999952316284 1.399999976158142 1.0)))
(test (gpu-unfull t5 1 4 4)
#4f((((1.0 2.0 3.0 3.299999952316284) (7.0 4.0 5.0 6.0) (1.100000023841858 7.0 8.0 9.0)
     (1.200000047683716 1.299999952316284 1.399999976158142 1.0)))))


(format (standard-output) "All tests are done~%")


