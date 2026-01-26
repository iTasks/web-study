;;;; 03-higher-order-functions.lisp
;;;; Higher-order functions in Common Lisp
;;;;
;;;; This file demonstrates functions that take or return other functions.

(format t "=== MAPCAR ===~%")

;;; mapcar - apply function to each element
(format t "Double each: ~a~%" 
        (mapcar (lambda (x) (* 2 x)) '(1 2 3 4 5)))

(format t "Square each: ~a~%" 
        (mapcar (lambda (x) (* x x)) '(1 2 3 4 5)))

(format t "Length of each: ~a~%" 
        (mapcar #'length '((1 2) (a b c) (x y z w))))

;;; mapcar with multiple lists
(format t "~%Add corresponding elements: ~a~%" 
        (mapcar #'+ '(1 2 3) '(10 20 30)))

(format t "=== REDUCE ===~%")

;;; reduce - accumulate values
(format t "Sum with reduce: ~a~%" 
        (reduce #'+ '(1 2 3 4 5)))

(format t "Product with reduce: ~a~%" 
        (reduce #'* '(1 2 3 4 5)))

(format t "Max with reduce: ~a~%" 
        (reduce #'max '(3 7 2 9 1 5)))

(format t "String concatenation: ~a~%" 
        (reduce (lambda (a b) (concatenate 'string a " " b))
                '("Hello" "Common" "Lisp")))

(format t "~%=== FILTER (REMOVE-IF-NOT) ===~%")

;;; Filter even numbers
(format t "Even numbers: ~a~%" 
        (remove-if-not #'evenp '(1 2 3 4 5 6 7 8 9 10)))

;;; Filter odd numbers
(format t "Odd numbers: ~a~%" 
        (remove-if-not #'oddp '(1 2 3 4 5 6 7 8 9 10)))

;;; Filter with lambda
(format t "Numbers > 5: ~a~%" 
        (remove-if-not (lambda (x) (> x 5)) '(1 3 5 7 9 11)))

(format t "~%=== REMOVE-IF ===~%")

;;; Remove negative numbers
(format t "Remove negatives: ~a~%" 
        (remove-if #'minusp '(-3 -1 0 2 4 -5 7)))

;;; Remove short strings
(format t "Remove short strings: ~a~%" 
        (remove-if (lambda (s) (< (length s) 4)) 
                   '("hi" "hello" "yo" "world" "a")))

(format t "~%=== EVERY and SOME ===~%")

;;; Check if all elements satisfy predicate
(format t "All positive? ~a~%" 
        (every #'plusp '(1 2 3 4 5)))

(format t "All even? ~a~%" 
        (every #'evenp '(2 4 6 8 10)))

(format t "All even (with odd)? ~a~%" 
        (every #'evenp '(2 4 5 8 10)))

;;; Check if any element satisfies predicate
(format t "~%Any negative? ~a~%" 
        (some #'minusp '(1 2 -3 4 5)))

(format t "Any > 100? ~a~%" 
        (some (lambda (x) (> x 100)) '(10 20 30 40)))

(format t "~%=== FUNCTION COMPOSITION ===~%")

;;; Compose functions
(defun compose (f g)
  "Return a function that is the composition of f and g"
  (lambda (x) (funcall f (funcall g x))))

(defvar *square-then-double* (compose (lambda (x) (* 2 x))
                                       (lambda (x) (* x x))))

(format t "Square then double 5: ~a~%" (funcall *square-then-double* 5))

(format t "~%=== RETURNING FUNCTIONS ===~%")

;;; Function that returns a function
(defun make-adder (n)
  "Return a function that adds n to its argument"
  (lambda (x) (+ x n)))

(defvar *add-10* (make-adder 10))
(defvar *add-100* (make-adder 100))

(format t "Add 10 to 5: ~a~%" (funcall *add-10* 5))
(format t "Add 100 to 5: ~a~%" (funcall *add-100* 5))

;;; Partial application
(defun partial (func &rest args1)
  "Partially apply a function"
  (lambda (&rest args2)
    (apply func (append args1 args2))))

(defvar *multiply-by-5* (partial #'* 5))
(format t "~%Multiply by 5: ~a~%" (funcall *multiply-by-5* 7))

(format t "~%=== FIND and POSITION ===~%")

;;; Find element satisfying predicate
(format t "Find first even: ~a~%" 
        (find-if #'evenp '(1 3 5 8 9 10)))

(format t "Position of first > 5: ~a~%" 
        (position-if (lambda (x) (> x 5)) '(1 2 3 6 7 8)))
