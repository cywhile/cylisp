(defpackage :checker
    (:use :common-lisp :cl :split-sequence)
    (:export :check))
(in package :checker)
(defvar *checker-answer-file* "checker-answer.txt")
(defvar *checker-config-file* "checker-config.txt")
(hmpq '(checkers chk-answers))
(defcls "checker" "checker" "一个检查者" "检查" 100 "中立")
(defun chk-init ()
    (progn
    (init-ans `(*checker-answer-file* *chk-answers*))
    (init-ers `(*checker-config-file* *checkers*))))
