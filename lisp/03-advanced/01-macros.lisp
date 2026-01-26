;;;; 01-macros.lisp
;;;; Macros and meta-programming in Common Lisp
;;;;
;;;; This file demonstrates the power of Lisp macros.

(format t "=== SIMPLE MACROS ===~%")

;;; Basic macro
(defmacro when-positive (x &body body)
  "Execute body only if x is positive"
  `(when (> ,x 0)
     ,@body))

(let ((value 5))
  (when-positive value
    (format t "Value ~a is positive~%" value)
    (format t "This is great!~%")))

;;; Macro expansion
(format t "~%Macro expansion:~%")
(format t "~a~%" (macroexpand-1 '(when-positive 10 (print "yes"))))

;;; Simple variable swap macro
(defmacro swap (a b)
  "Swap values of two variables"
  `(let ((temp ,a))
     (setf ,a ,b)
     (setf ,b temp)))

(let ((x 10) (y 20))
  (format t "~%Before swap: x=~a, y=~a~%" x y)
  (swap x y)
  (format t "After swap: x=~a, y=~a~%" x y))

(format t "~%=== CONTROL STRUCTURE MACROS ===~%")

;;; Custom until loop
(defmacro until (condition &body body)
  "Loop until condition is true"
  `(loop
     (when ,condition
       (return))
     ,@body))

(let ((count 0))
  (format t "Counting with until:~%")
  (until (>= count 5)
    (format t "  Count: ~a~%" count)
    (incf count)))

;;; Custom for-each macro
(defmacro for-each ((var list) &body body)
  "Iterate over each element in list"
  `(dolist (,var ,list)
     ,@body))

(format t "~%For-each demo:~%")
(for-each (item '(apple banana cherry))
  (format t "  Fruit: ~a~%" item))

(format t "~%=== CODE GENERATION MACROS ===~%")

;;; Generate getter/setter
(defmacro define-accessors (name)
  "Define getter and setter for a variable"
  (let ((var-name (intern (format nil "*~a*" name)))
        (getter (intern (format nil "GET-~a" name)))
        (setter (intern (format nil "SET-~a" name))))
    `(progn
       (defvar ,var-name nil)
       (defun ,getter () ,var-name)
       (defun ,setter (value) (setf ,var-name value)))))

(define-accessors counter)
(set-counter 42)
(format t "Counter value: ~a~%" (get-counter))

;;; Generate multiple function definitions
(defmacro define-math-ops (op)
  "Define wrapper for math operation"
  (let ((func-name (intern (format nil "MY-~a" op))))
    `(defun ,func-name (a b)
       (,op a b))))

(define-math-ops +)
(define-math-ops *)
(format t "~%MY-+: ~a~%" (my-+ 5 3))
(format t "MY-*: ~a~%" (my-* 5 3))

(format t "~%=== ANAPHORIC MACROS ===~%")

;;; Anaphoric if (creates implicit 'it' variable)
(defmacro aif (test then &optional else)
  "Anaphoric if - test result bound to 'it'"
  `(let ((it ,test))
     (if it ,then ,else)))

(aif (find 3 '(1 2 3 4 5))
     (format t "Found it at position: ~a~%" it)
     (format t "Not found~%"))

;;; Anaphoric when
(defmacro awhen (test &body body)
  "Anaphoric when - test result bound to 'it'"
  `(let ((it ,test))
     (when it ,@body)))

(awhen (+ 10 20)
  (format t "~%Result available as 'it': ~a~%" it))

(format t "~%=== WITH- MACROS ===~%")

;;; Custom with-timing macro
(defmacro with-timing (&body body)
  "Execute body and report execution time"
  `(let ((start (get-internal-real-time)))
     (progn ,@body)
     (let ((end (get-internal-real-time)))
       (format t "~%Execution time: ~,3f seconds~%"
               (/ (- end start) internal-time-units-per-second)))))

(with-timing
  (format t "Computing factorial...~%")
  (loop for i from 1 to 1000000 do (* i 2)))

(format t "~%=== READER MACROS (info only) ===~%")
(format t "'(1 2 3) is reader macro for (quote (1 2 3))~%")
(format t "`(a ,b) is reader macro for backquote/comma~%")
(format t "#'func is reader macro for (function func)~%")

(format t "~%=== MACRO UTILITIES ===~%")

;;; Gensym for hygienic macros
(defmacro safe-swap (a b)
  "Swap using gensym to avoid variable capture"
  (let ((temp (gensym)))
    `(let ((,temp ,a))
       (setf ,a ,b)
       (setf ,b ,temp))))

(format t "Generated symbol: ~a~%" (gensym))
(format t "Generated symbol: ~a~%" (gensym "MY-VAR-"))

(format t "~%=== PRACTICAL MACRO EXAMPLE ===~%")

;;; Define a simple DSL for assertions
(defmacro assert-equal (expected actual)
  "Simple assertion macro"
  `(let ((exp ,expected)
         (act ,actual))
     (if (equal exp act)
         (format t "✓ PASS: ~a = ~a~%" exp act)
         (format t "✗ FAIL: Expected ~a, got ~a~%" exp act))))

(assert-equal 4 (+ 2 2))
(assert-equal 5 (+ 2 2))
(assert-equal "hello" (concatenate 'string "hel" "lo"))
