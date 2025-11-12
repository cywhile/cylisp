(defpackage :analyzer
  (:use :cl :split-sequence)
  (:export :ana-init :append-role-to-file :check :analyzer :main-analyze))

(in-package :analyzer)

(defvar *ana-answer-file* "analyzer-answer.txt")
(defvar *ana-config-file* "analyzer-config.txt")
(defvar *know-or-not* t)
(defvar *ana-answer* (make-hash-table :test 'equal))
(defvar *analyzers* (make-hash-table :test 'equal))

(defun ana-init (filename)
  (when (probe-file filename)
    (with-open-file (stream filename :direction :input)
      (loop for line = (read-line stream nil)
            while line
            do (let ((parts (split-sequence #\| line)))
                 (when (= (length parts) 2)
                   (setf (gethash (first parts) *ana-answer*)
                         (second parts))))))))

(defun append-role-to-file (filename topic explain)
  (with-open-file (out filename
                      :direction :output
                      :if-exists :append
                      :if-does-not-exist :create)
    (format out "~a|~a~%" topic explain))
  (values topic explain))

(defun check (str)
  (let ((answer (gethash str *ana-answer*)))
    (if answer
        answer
        (progn
          (append-role-to-file *ana-answer-file* str "不清楚")
          "什么我不是很清楚，这是一个暂未记录的奇怪问题..."))))

(defclass analyzer ()
  ((name :initarg :name :accessor ana-name :initform "智慧的分析者")
   (rspon :initarg :rspon :accessor ana-rspon :initform "分析")
   (price :initarg :price :accessor ana-price :initform 100)
   (tht :initarg :tht :accessor ana-tht :initform "中立")))

(defun init-analyzer (filename)
  (when (probe-file filename)
    (with-open-file (stream filename :direction :input)
      (loop for line = (read-line stream nil)
            while line
            do (let ((parts (split-sequence #\| line)))
                 (when (= (length parts) 5)
                   (destructuring-bind (a b c d e) parts
                     (setf (gethash a *analyzers*) (list b c d e)))))))))
(defun main-analyze (str whoana)
  (format t "你好！我是~a!~%" (ana-name whoana))
  (sleep 0.5)
  (format t "我的工作是~a~%" (ana-rspon whoana))
  (sleep 0.5)
  (format t "你输入的问题是~a~%" str)
  (sleep 0.5)
  (format t "我正在分析你的问题...~%")
  (sleep 3)
  (let ((result (check str)))
    (if (not (string= result "什么我不是很清楚，这是一个暂未记录的奇怪问题..."))
        (progn
          (format t "以~a的态度分析，你的问题主要关于~a~%" (ana-tht whoana) result)
          (format t "价格：~a~%" (ana-price whoana)))
        (progn
          (format t "关于这个问题，这是：~a~%" result)
          (format t "请输入你的答案： ")
          (let ((user-answer (read-line)))
            (append-role-to-file *ana-answer-file* str user-answer)
            (setf (gethash str *ana-answer*) user-answer)
            (format t "感谢您的教导！我又学会了新的知识~%")
            (setf *know-or-not* nil))))))

(defun analyzer-instance (analyzer-list)
  (maphash
   (lambda (k v)
     (let ((sym (intern (format nil "ANALYZER-~A" k))))
       (set sym
            (make-instance 'analyzer
              :name (first v)
              :rspon (second v)
              :price (third v)
              :tht (fourth v)))))
   analyzer-list))
(defun init-all ()
  (ana-init *ana-config-file*)
  (init-analyzer *ana-answer-file*))
