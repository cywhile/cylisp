;;;; ============================================================
;;;; Lisp 异常处理（condition system）示例 —— 带详细注释
;;;; ============================================================

;;; 定义一个函数 risky-divide，用于做除法
;;; 这个函数内部定义了一个“重启方案”，
;;; 当出现除以 0 的错误时，可以从外部调用它来“修复”。
(defun risky-divide (a b)
  ;; restart-case 的语法：
  ;; (restart-case 主表达式
  ;;   (重启名 (参数...) [关键字参数] 重启执行体...))
  ;; 主表达式执行时若出错，可以调用其中定义的重启。
  (restart-case
      ;; 主表达式：执行 a 除以 b
      (/ a b)

    ;; 定义一个名为 use-another-value 的“重启方案”
    ;; 它有一个参数 new-b，用来接收新的除数。
    (use-another-value (new-b)
      ;; :report 只是提示用的文字，可忽略。
      :report "提供一个新的除数来重新尝试除法"
      ;; 如果调用 (invoke-restart 'use-another-value 1)
      ;; 那么这里 new-b = 1
      ;; 就会执行 (/ a 1)
      (/ a new-b))))

;;; ============================================================

;;; 定义一个“安全运行”的函数 safe-run，
;;; 它会捕获除零错误并自动调用上面的重启方案。
(defun safe-run ()
  ;; handler-bind 语法：
  ;; (handler-bind ((条件类型 处理函数)) 主体代码)
  ;; 当执行主体代码时，如果出现匹配的条件，就调用处理函数。
  (handler-bind
      ;; 绑定一个条件类型：division-by-zero（除以零错误）
      ;; 对应的处理函数是一个匿名函数 lambda
      ((division-by-zero
         (lambda (c)
           ;; 打印提示
           (format t "捕获到除零错误，尝试修复...~%")
           ;; 调用上面定义的重启点 use-another-value
           ;; 并传入参数 1（表示改用 1 来做除数）
           (invoke-restart 'use-another-value 9))))

    ;; handler-bind 的主体部分：
    ;; 执行 risky-divide，并打印结果。
    (format t "结果：~A~%" (risky-divide 10 0))
    ;; 如果程序能走到这里，说明错误已被修复。
    (format t "程序继续运行~%")))
(safe-run)
;;; ============================================================

;;; 运行：
;;;   (safe-run)
;;;
;;; 输出：
;;;   捕获到除零错误，尝试修复...
;;;   结果：10
;;;   程序继续运行
;;;
;;; ============================================================

;;; 运行流程概述：
;;;
;;; 1. safe-run 启动时，设置一个除零错误的 handler。
;;; 2. 执行 risky-divide(10, 0)
;;; 3. risky-divide 尝试计算 (/ 10 0)
;;;    → 触发 division-by-zero 条件。
;;; 4. 外层 handler 捕获到这个条件，打印提示，
;;;    然后调用 (invoke-restart 'use-another-value 1)。
;;; 5. 这会跳回 risky-divide 的 restart-case，
;;;    执行 (/ 10 1)，返回 10。
;;; 6. 打印结果 10，并继续执行剩下的代码。
;;;
;;; 整个过程没有程序崩溃，而是自动“修复”后继续运行。
(defun out (a b)
  "递归输出 a 共 b 次。"
  (if (= b 0)
      (progn
        (format t "haolashuowanla~%")
        (force-output))  ; 确保最后一行立即输出
      (progn
        (format t "~A~%" a)
        (force-output)   ; 每次都强制刷新
        (out a (1- b))))) ; 递归调用

(defun speak (a b)
  (format t "欢迎与我对话！你的数字是 ~A 和 ~A~%" a b)
  (force-output)
  (let ((real-b
         (restart-case
             (/ a b)
           (use-default-b (new-b)
             (format t "让玄鹤给你一个 b 吧（~A）~%" new-b)
             (force-output)
             (/ a new-b)
             new-b)))) ; 返回 new-b 给 real-b
    (out a real-b)))

(defun safe-speak ()
  "安全执行 speak，自动处理除零。"
  (handler-bind
      ((division-by-zero
         (lambda (c)
           (declare (ignore c))
           (format t "你怎么不好好 b 啊~%")
           (force-output)
           (invoke-restart 'use-default-b 7))))
    (speak 9 0)
    (format t "玄鹤帮你改好啦！~%")
    (force-output)
    (values))) ; 不让 REPL 再打印返回值

;; ✅ 执行
(safe-speak)