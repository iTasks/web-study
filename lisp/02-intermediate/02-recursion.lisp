;;;; 02-recursion.lisp
;;;; Recursion in Common Lisp
;;;;
;;;; This file demonstrates recursive programming techniques.

(format t "=== BASIC RECURSION ===~%")

;;; Simple recursive factorial
(defun factorial (n)
  "Calculate factorial recursively"
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(format t "Factorial of 5: ~a~%" (factorial 5))
(format t "Factorial of 10: ~a~%" (factorial 10))

;;; Fibonacci sequence
(defun fibonacci (n)
  "Calculate nth Fibonacci number"
  (cond
    ((<= n 0) 0)
    ((= n 1) 1)
    (t (+ (fibonacci (- n 1))
          (fibonacci (- n 2))))))

(format t "~%Fibonacci sequence (first 10):~%")
(dotimes (i 10)
  (format t "fib(~a) = ~a~%" i (fibonacci i)))

;;; List recursion - sum
(format t "~%=== LIST RECURSION ===~%")

(defun sum-list (lst)
  "Sum all numbers in a list recursively"
  (if (null lst)
      0
      (+ (car lst) (sum-list (cdr lst)))))

(format t "Sum of (1 2 3 4 5): ~a~%" (sum-list '(1 2 3 4 5)))

;;; List recursion - length
(defun my-length (lst)
  "Calculate length of list recursively"
  (if (null lst)
      0
      (+ 1 (my-length (cdr lst)))))

(format t "Length of (a b c d e): ~a~%" (my-length '(a b c d e)))

;;; List recursion - reverse
(defun my-reverse (lst)
  "Reverse a list recursively"
  (if (null lst)
      nil
      (append (my-reverse (cdr lst)) (list (car lst)))))

(format t "Reverse of (1 2 3 4 5): ~a~%" (my-reverse '(1 2 3 4 5)))

;;; Tail recursion (more efficient)
(format t "~%=== TAIL RECURSION ===~%")

(defun factorial-tail (n &optional (acc 1))
  "Tail-recursive factorial"
  (if (<= n 1)
      acc
      (factorial-tail (- n 1) (* n acc))))

(format t "Tail factorial of 100: ~a~%" (factorial-tail 100))

;;; Tail-recursive list sum
(defun sum-list-tail (lst &optional (acc 0))
  "Tail-recursive list sum"
  (if (null lst)
      acc
      (sum-list-tail (cdr lst) (+ acc (car lst)))))

(format t "Tail sum of (10 20 30 40): ~a~%" (sum-list-tail '(10 20 30 40)))

;;; Tree recursion - depth
(format t "~%=== TREE RECURSION ===~%")

(defun tree-depth (tree)
  "Calculate the depth of a tree structure"
  (if (atom tree)
      0
      (+ 1 (apply #'max (mapcar #'tree-depth tree)))))

(format t "Depth of (1 (2 (3 4)) 5): ~a~%" 
        (tree-depth '(1 (2 (3 4)) 5)))

;;; Mutual recursion
(format t "~%=== MUTUAL RECURSION ===~%")

(defun is-even (n)
  "Check if number is even using mutual recursion"
  (if (= n 0)
      t
      (is-odd (- n 1))))

(defun is-odd (n)
  "Check if number is odd using mutual recursion"
  (if (= n 0)
      nil
      (is-even (- n 1))))

(format t "Is 7 even? ~a~%" (is-even 7))
(format t "Is 8 even? ~a~%" (is-even 8))
