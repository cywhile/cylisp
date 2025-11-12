;;;这里会有一些宏
;;;我们用他们来定义DSL
(defun display (num key value)
    (print "第~a个符合要求的是~a，~a " num key value))
(defmacro who (wch wht)
  `(let ((n 1))
     (maphash
       (lambda (key value)
        (let((name  (first value))
             (rspom (second value))
             (price (third value))
             (tht   (fourth value)))
         (when (and (listp value)
                    (= ,wch ,wht)) ; 这里的 cnd 会展开为一个表达式
           (display n key value)
           (setq n (1+ n))))
       *analyzers*)))) ; 假设你要遍历的是
;;;(who name "xuanhe")
(defmacro hmpq (namelist)
  `(progn
     ,@(mapcar (lambda (name)
                 (let* ((lower (string-downcase (symbol-name name)))
                        (sym (intern (format nil "*~A*" lower) :cl-user)))
                   `(defvar ,sym (make-hash-table :test 'equal))))
               namelist)))
;;;创建一堆哈希表
(defmacro init-ans (filename name)
  `(when (probe-file ,filename)
    (with-open-file (stream ,filename :direction :input)
      (loop for line = (read-line stream nil)
            while line
            do (let ((parts (split-sequence #\| line)))
                 (when (= (length parts) 2)
                   (setf (gethash (first parts) ,name)
                         (second parts))))))))
;;;初始化答案键值对
(defmacro init-ers (filename name)
  `(when (probe-file ,filename)
    (with-open-file (stream ,filename :direction :input)
      (loop for line = (read-line stream nil)
            while line
            do (let ((parts (split-sequence #\| line)))
                 (when (= (length parts) 5)
                   (destructuring-bind (a b c d e) parts
                     (setf (gethash a ,name) (list b c d e)))))))))
;;;初始化我们的类实例键值对表
          
(defmacro instance (lst cls name-way)
  `(progn
     ,@(let (forms)
         (maphash
          (lambda (k v)
            (let ((sym (intern (format nil "~A-~A" name-way k) :cl-user)))
              (push `(set ',sym
                          (make-instance ',cls
                            :name ,(first v)
                            :rspon ,(second v)
                            :price ,(third v)
                            :tht ,(fourth v)))
                    forms)))
          lst)
         (nreverse forms))))
;;;又是一个美妙的实例化宏，记得告诉我你的名字哦
(defmacro defcls (nme nam str1 str2 int3 str4)
  (let* ((nam1 (intern (format nil "~A-~A" nam "name") :cl-user))
         (nam2 (intern (format nil "~A-~A" nam "rspon") :cl-user))
         (nam3 (intern (format nil "~A-~A" nam "price") :cl-user))
         (nam4 (intern (format nil "~A-~A" nam "tht") :cl-user)))
    `(defclass ,nme ()
       ((name  :initarg :name  :accessor ,nam1 :initform ,str1)
        (rspon :initarg :rspon :accessor ,nam2 :initform ,str2)
        (price :initarg :price :accessor ,nam3 :initform ,int3)
        (tht   :initarg :tht   :accessor ,nam4 :initform ,str4)))))
;;;小哥哥好厉害啊！！不愧是小哥哥呢！
