(defpackage analyzer 
    (:use :cl)
    (:export :ana))
(in-package :analyzer)
;这是全局变量，存储答案
(defvar *ana-answer* (make-hash-table :test 'equal))
;这是初始化函数，读取答案文件
(defun ana-init (filename)
    (with-open-file (stream "analyzer-answer.txt" :direction :input)
    (loop for line = (read-line stream nil)
        while line
        do (let (parts (split-sequence:split-sequence #\| line))
            (when (= (length parts ) 2)
                (setf (gethash (first parts) *ana-answer*) (second parts)))))))
(defun append-role-to-file (filename topic explain)
    (with-open-file (out filename
                       :direction :output
                       :if-exists :append)
    (format out "~a|~a~%" name greeting)))
(defun check (str)
    (if (gethash str *ana-answer*)
        (gethash str *ana-answer*)
        (progn
            (append-role-to-file "analyzer-answer.txt" str "不清楚")
            ("什么我不是很清楚，这是一个暂未记录的奇怪问题..."))))
(defclass analyzer ()
  ((name :initarg :name :accessor ana-name :initform "智慧的分析者")
   (rspon  :initarg :rspon  :accessor ana-rspon  :initform "分析")
   (price :initarg :price :accessor ana-price :initform 100)
   (tht :initarg :tht  :accessor ana-tht  :initform "中立")))
(defun main-analyze (str whoana) 
    (print "你好！我是~a!" (ana-name whoana))
    (sleep 0.5)
    (print "我的工作是~a")(ana-rspon whoana)
    (sleep 0.5)
    (print "你输入的问题是~a~%" str)
    (sleep 0.5)
    (print "我正在分析你的问题...")
    (sleep 3)
    (if (check str)
    (progn
        (print "从~a的角度分析，你的问题主要关于~a~%" (ana-tht whoana) (check str))
        (sleep 0.5)
        (print "price ： ~a")(ana-price whoana))
    (progn
        (print "关于这是~a"(check str))
        (format t "你能告诉我一些关于这个问题的答案吗？")
        (append-role-to-file "analyzer-answer.txt" str (read-line))
        (print "感谢您的教导！我又学会了新的知识"))))