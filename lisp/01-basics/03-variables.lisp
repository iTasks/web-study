;;;; 03-variables.lisp
;;;; Working with variables in Common Lisp
;;;;
;;;; This file demonstrates variable definition and manipulation.

;;; Global variables with defvar
(defvar *global-counter* 0
  "A global counter variable")

;;; Global constants with defparameter (can be reassigned)
(defparameter *pi* 3.14159
  "An approximation of pi")

;;; Global constants with defconstant (cannot be reassigned)
(defconstant +max-size+ 100
  "Maximum allowed size")

;;; Display global variables
(format t "Global counter: ~a~%" *global-counter*)
(format t "Pi constant: ~a~%" *pi*)
(format t "Max size: ~a~%" +max-size+)

;;; Local variables with let
(let ((x 10)
      (y 20))
  (format t "~%Inside let block:~%")
  (format t "  x = ~a~%" x)
  (format t "  y = ~a~%" y)
  (format t "  x + y = ~a~%" (+ x y)))

;;; Sequential binding with let*
(let* ((a 5)
       (b (* a 2)))  ; b can use a's value
  (format t "~%Inside let* block:~%")
  (format t "  a = ~a~%" a)
  (format t "  b = 2 * a = ~a~%" b))

;;; Setting values with setf
(format t "~%Setting values:~%")
(let ((count 0))
  (format t "  Initial count: ~a~%" count)
  (setf count 10)
  (format t "  After setf: ~a~%" count)
  (incf count)
  (format t "  After incf: ~a~%" count)
  (decf count 5)
  (format t "  After decf 5: ~a~%" count))

;;; Multiple value binding
(format t "~%Multiple values:~%")
(let ((name "Alice")
      (age 30)
      (city "Boston"))
  (format t "  Name: ~a, Age: ~a, City: ~a~%" name age city))
