(defparameter add 0)
(defparameter in 10)
(defun jish (n)
  (if (> add in)
      (1- n)
      (progn
      (setf add (+ (/ 1.0 n) add))
      (jish (+ 1 n)))))
(print (jish 1))
;hello~
