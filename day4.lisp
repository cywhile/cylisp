(defmacro when-positive (number then-body else-body)
  `(if (> ,number 0)
       ,then-body
       ,else-body))
(when-positive 5
    (print "helloworld")
    (print "kali linux "))
(defmacro for (var start end &body body)
  `(do ((,var ,start (1+ ,var)))
       ((> ,var ,end))
     ,@body))
(for i 1 5
    (print "xuanhe xuanhe "))
(defmacro make-printer (name)
  `(defmacro ,name ()
     `(print "hi")))
;;; ===============================
;;; 🧠 Mini Lisp Evaluator
;;; 支持常量、变量、define、if、函数调用
;;; ===============================

;;; 环境是一个关联表（alist），形如 ((x . 10) (y . 20))

;;; ===============================
;;; 🧠 Mini Lisp Evaluator（完整版）
;;; 支持常量、变量、define、if、函数调用
;;; ===============================

;;; 定义全局环境，包含基本函数
(defparameter *global-env*
  (list
   (cons '+ #'+)
   (cons '- #'-)
   (cons '* #'*)
   (cons '/ #'/)
   (cons '= #'=)
   (cons 'print #'print)))

;;; 主解释器函数
(defun eval-expr (expr env)
  "解释一个 Lisp 表达式 expr，在给定的环境 env 中求值。"
  (cond
    ;; ----------------------------
    ;; 1. 原子表达式（数字或变量）
    ;; ----------------------------
    ((atom expr)
     (cond
       ((numberp expr) expr) ; 数字直接返回
       ((symbolp expr)       ; 符号：查环境
        (let ((binding (assoc expr env)))
          (if binding
              (cdr binding)
              (error "变量 ~A 未定义" expr))))
       (t (error "无法识别的原子表达式：~A" expr))))

    ;; ----------------------------
    ;; 2. 特殊形式：define
    ;; (define x 42)
    ;; ----------------------------
    ((eq (car expr) 'define)
     (let ((name (cadr expr))
           (value (eval-expr (caddr expr) env)))
       ;; 修改环境（副作用）
       (push (cons name value) *global-env*) ; 修改的是全局环境
       (format t "定义变量 ~A = ~A~%" name value)
       name)) ; 返回变量名作为结果

    ;; ----------------------------
    ;; 3. 特殊形式：if
    ;; (if 条件 分支1 分支2)
    ;; ----------------------------
    ((eq (car expr) 'if)
     (let ((test (eval-expr (cadr expr) env)))
       (if test
           (eval-expr (caddr expr) env)
           (eval-expr (cadddr expr) env))))

    ;; ----------------------------
    ;; 4. 函数调用
    ;; 形如：(+ 1 2) 或 (* x 3)
    ;; ----------------------------
    (t
     (let* ((fn (eval-expr (car expr) env)) ; 先求函数
            (args (mapcar (lambda (arg)
                            (eval-expr arg env))
                          (cdr expr))))     ; 再求参数
       (apply fn args))))) ; 应用函数

;;; ===============================
;;; 🧪 测试用例（直接运行）
;;; ===============================

(format t "~%结果1: ~A~%" (eval-expr '(+ 1 2) *global-env*)) ; => 3

(eval-expr '(define x 10) *global-env*) ; 定义变量 x

(format t "~%结果2: ~A~%" (eval-expr '(* x 3) *global-env*)) ; => 30

(format t "~%结果3: ~A~%" (eval-expr '(if (= x 10)
                                          (+ x 1)
                                          0)
                                     *global-env*)) ; => 11
 ; => 11
