(defpackage :analyzer
  (:use :cl :split-sequence)
  (:export :ana-init :append-role-to-file :check :analyzer :main-analyze))

(in-package :analyzer)

(defvar *know-or-not* t
  "全局变量，表示是否知道答案。")

(defvar *ana-answer* (make-hash-table :test 'equal)
  "全局哈希表，存储已知问题及对应答案。")

;;; 初始化函数，读取答案文件并写入哈希表
(defun ana-init (filename)
  (with-open-file (stream filename :direction :input :if-does-not-exist :create)
    (loop for line = (read-line stream nil)
          while line
          do (let ((parts (split-sequence #\| line)))
               (when (= (length parts) 2)
                 (setf (gethash (first parts) *ana-answer*) (second parts)))))))

;;; 向文件追加主题和解释
(defun append-role-to-file (filename topic explain)
  (with-open-file (out filename
                      :direction :output
                      :if-exists :append
                      :if-does-not-exist :create)
    (format out "~a|~a~%" topic explain)))

;;; 检查str是否有答案，没有则追加并返回默认回复
(defun check (str)
  (let ((answer (gethash str *ana-answer*)))
    (if answer
        answer
        (progn
          (append-role-to-file "analyzer-answer.txt" str "不清楚")
          "什么我不是很清楚，这是一个暂未记录的奇怪问题..."))))

(defclass analyzer ()
  ((name :initarg :name :accessor ana-name :initform "智慧的分析者")
   (rspon :initarg :rspon :accessor ana-rspon :initform "分析")
   (price :initarg :price :accessor ana-price :initform 100)
   (tht :initarg :tht :accessor ana-tht :initform "中立")))

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
          (format t "从~a的角度分析，你的问题主要关于~a~%" (ana-tht whoana) result)
          (sleep 0.5)
          (format t "价格：~a~%" (ana-price whoana)))
        (progn
          (format t "关于这个问题，这是：~a~%" result)
          (format t "你能告诉我一些关于这个问题的答案吗？~%")
          (let ((user-answer (read-line)))
            (append-role-to-file "analyzer-answer.txt" str user-answer)
            (setf (gethash str *ana-answer*) user-answer)
            (format t "感谢您的教导！我又学会了新的知识~%")
            (setf *know-or-not* nil))))))

;; 对外接口示例（如需在 REPL 交互，可使用以下典型流程）：
;; (ana-init "analyzer-answer.txt")
;; (let ((a (make-instance 'analyzer)))
;;   (main-analyze "xxx问题" a))
