;;;; 01-functions.lisp
;;;; Functions in Common Lisp
;;;;
;;;; This file demonstrates function definition and usage.

(format t "=== BASIC FUNCTIONS ===~%")

;;; Simple function definition
(defun greet (name)
  "Greet a person by name"
  (format t "Hello, ~a!~%" name))

(greet "Alice")
(greet "Bob")

;;; Function with multiple parameters
(defun add (a b)
  "Add two numbers"
  (+ a b))

(format t "~%5 + 3 = ~a~%" (add 5 3))

;;; Function with return value
(defun square (x)
  "Return the square of a number"
  (* x x))

(format t "Square of 7: ~a~%" (square 7))

;;; Function with multiple statements
(defun calculate-area (radius)
  "Calculate the area of a circle"
  (let ((pi 3.14159))
    (format t "Calculating area for radius ~a~%" radius)
    (* pi radius radius)))

(format t "~%Area: ~a~%" (calculate-area 5))

;;; Optional parameters
(format t "~%=== OPTIONAL PARAMETERS ===~%")

(defun greet-with-title (&optional (name "Guest") (title "Mr."))
  "Greet with optional title and name"
  (format t "Hello, ~a ~a!~%" title name))

(greet-with-title)
(greet-with-title "Smith")
(greet-with-title "Johnson" "Dr.")

;;; Keyword parameters
(format t "~%=== KEYWORD PARAMETERS ===~%")

(defun make-person (&key name age city)
  "Create a person description"
  (format t "Name: ~a, Age: ~a, City: ~a~%" 
          (or name "Unknown")
          (or age "Unknown")
          (or city "Unknown")))

(make-person :name "Alice" :age 30 :city "Boston")
(make-person :name "Bob" :city "Seattle")
(make-person :age 25)

;;; Rest parameters
(format t "~%=== REST PARAMETERS ===~%")

(defun sum (&rest numbers)
  "Sum all provided numbers"
  (apply #'+ numbers))

(format t "Sum of 1,2,3,4,5: ~a~%" (sum 1 2 3 4 5))
(format t "Sum of 10,20,30: ~a~%" (sum 10 20 30))

;;; Local functions with labels
(format t "~%=== LOCAL FUNCTIONS ===~%")

(defun factorial-iter (n)
  "Calculate factorial using local function"
  (labels ((fact-helper (n acc)
             (if (<= n 1)
                 acc
                 (fact-helper (- n 1) (* n acc)))))
    (fact-helper n 1)))

(format t "Factorial of 5: ~a~%" (factorial-iter 5))
(format t "Factorial of 10: ~a~%" (factorial-iter 10))

;;; Anonymous functions (lambda)
(format t "~%=== LAMBDA FUNCTIONS ===~%")

(defvar *multiply* (lambda (x y) (* x y)))
(format t "Lambda multiply 4 * 5: ~a~%" (funcall *multiply* 4 5))

;;; Using lambda in mapcar
(format t "Double each: ~a~%" 
        (mapcar (lambda (x) (* 2 x)) '(1 2 3 4 5)))
