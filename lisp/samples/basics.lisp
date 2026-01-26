;;;; basics.lisp
;;;; Demonstrates fundamental Common Lisp features

;;; ============================================================================
;;; Variables and Constants
;;; ============================================================================

(defconstant +pi+ 3.14159 "Pi constant")
(defparameter *greeting* "Hello, Lisp!" "Global dynamic variable")
(defvar *counter* 0 "Global variable")

;;; ============================================================================
;;; Functions
;;; ============================================================================

(defun greet (name)
  "Simple greeting function."
  (format t "Hello, ~a!~%" name))

(defun add (a b)
  "Add two numbers."
  (+ a b))

(defun factorial (n)
  "Calculate factorial recursively."
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(defun factorial-iterative (n)
  "Calculate factorial iteratively using loop."
  (loop for i from 1 to n
        for result = 1 then (* result i)
        finally (return result)))

;;; ============================================================================
;;; List Operations
;;; ============================================================================

(defun list-examples ()
  "Demonstrate list operations."
  (let ((my-list '(1 2 3 4 5)))
    (format t "Original list: ~a~%" my-list)
    (format t "First element: ~a~%" (car my-list))
    (format t "Rest of list: ~a~%" (cdr my-list))
    (format t "Second element: ~a~%" (cadr my-list))
    (format t "List length: ~a~%" (length my-list))
    (format t "Reversed: ~a~%" (reverse my-list))
    (format t "Append: ~a~%" (append my-list '(6 7 8)))))

;;; ============================================================================
;;; Higher-Order Functions
;;; ============================================================================

(defun map-examples ()
  "Demonstrate higher-order functions."
  (let ((numbers '(1 2 3 4 5)))
    (format t "Original: ~a~%" numbers)
    (format t "Doubled (mapcar): ~a~%" 
            (mapcar (lambda (x) (* x 2)) numbers))
    (format t "Evens (remove-if-not): ~a~%" 
            (remove-if-not #'evenp numbers))
    (format t "Sum (reduce): ~a~%" 
            (reduce #'+ numbers))))

;;; ============================================================================
;;; Conditional Logic
;;; ============================================================================

(defun check-number (n)
  "Classify a number."
  (cond
    ((zerop n) "zero")
    ((plusp n) "positive")
    ((minusp n) "negative")
    (t "unknown")))

(defun grade-letter (score)
  "Convert numeric grade to letter grade."
  (cond
    ((>= score 90) "A")
    ((>= score 80) "B")
    ((>= score 70) "C")
    ((>= score 60) "D")
    (t "F")))

;;; ============================================================================
;;; Data Structures
;;; ============================================================================

(defstruct person
  "Person structure."
  name
  age
  occupation)

(defun person-examples ()
  "Demonstrate struct usage."
  (let ((p (make-person :name "Alice" :age 30 :occupation "Engineer")))
    (format t "Person: ~a~%" p)
    (format t "Name: ~a~%" (person-name p))
    (format t "Age: ~a~%" (person-age p))
    (format t "Occupation: ~a~%" (person-occupation p))))

;;; ============================================================================
;;; Association Lists (Alists)
;;; ============================================================================

(defun alist-examples ()
  "Demonstrate association lists."
  (let ((contacts '((alice . "alice@example.com")
                    (bob . "bob@example.com")
                    (charlie . "charlie@example.com"))))
    (format t "Contacts: ~a~%" contacts)
    (format t "Alice's email: ~a~%" (cdr (assoc 'alice contacts)))
    (format t "Bob's email: ~a~%" (cdr (assoc 'bob contacts)))))

;;; ============================================================================
;;; Hash Tables
;;; ============================================================================

(defun hash-table-examples ()
  "Demonstrate hash tables."
  (let ((scores (make-hash-table :test 'equal)))
    (setf (gethash "Alice" scores) 95)
    (setf (gethash "Bob" scores) 87)
    (setf (gethash "Charlie" scores) 92)
    
    (format t "Alice's score: ~a~%" (gethash "Alice" scores))
    (format t "All scores:~%")
    (maphash (lambda (k v)
               (format t "  ~a: ~a~%" k v))
             scores)))

;;; ============================================================================
;;; Main Demo
;;; ============================================================================

(defun demo ()
  "Run all demonstrations."
  (format t "~%=== BASIC FUNCTIONS ===~%")
  (greet "World")
  (format t "5 + 3 = ~a~%" (add 5 3))
  (format t "5! = ~a~%" (factorial 5))
  (format t "5! (iterative) = ~a~%" (factorial-iterative 5))
  
  (format t "~%=== LIST OPERATIONS ===~%")
  (list-examples)
  
  (format t "~%=== HIGHER-ORDER FUNCTIONS ===~%")
  (map-examples)
  
  (format t "~%=== CONDITIONALS ===~%")
  (format t "0 is ~a~%" (check-number 0))
  (format t "5 is ~a~%" (check-number 5))
  (format t "-3 is ~a~%" (check-number -3))
  (format t "Score 85 is grade ~a~%" (grade-letter 85))
  
  (format t "~%=== DATA STRUCTURES ===~%")
  (person-examples)
  
  (format t "~%=== ASSOCIATION LISTS ===~%")
  (alist-examples)
  
  (format t "~%=== HASH TABLES ===~%")
  (hash-table-examples))

;;; Run demo
(demo)
