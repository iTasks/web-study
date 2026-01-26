;;;; example-tests.lisp
;;;; Example test suite using FiveAM
;;;;
;;;; This demonstrates how to write tests for Common Lisp code.
;;;;
;;;; To run these tests:
;;;; 1. Install Quicklisp and FiveAM:
;;;;    (ql:quickload :fiveam)
;;;; 2. Load this file:
;;;;    (load "example-tests.lisp")
;;;; 3. Run tests:
;;;;    (fiveam:run! 'basic-tests)

;; Note: This requires FiveAM to be installed via Quicklisp
;; Uncomment the following line to load FiveAM:
;; (ql:quickload :fiveam)

(format t "~%=== EXAMPLE TEST SUITE ===~%~%")

(format t "This file demonstrates testing Common Lisp code.~%")
(format t "To actually run these tests, you need:~%")
(format t "  1. Quicklisp installed~%")
(format t "  2. FiveAM loaded: (ql:quickload :fiveam)~%~%")

;; Test examples (commented out unless FiveAM is loaded)

#|

;;; Define test suite
(fiveam:def-suite basic-tests
  :description "Basic arithmetic and list tests")

(fiveam:in-suite basic-tests)

;;; Arithmetic tests
(fiveam:test addition
  "Test addition operation"
  (fiveam:is (= 4 (+ 2 2)))
  (fiveam:is (= 0 (+ -5 5)))
  (fiveam:is (= 100 (+ 40 60))))

(fiveam:test subtraction
  "Test subtraction operation"
  (fiveam:is (= 0 (- 5 5)))
  (fiveam:is (= 5 (- 10 5)))
  (fiveam:is (= -5 (- 5 10))))

(fiveam:test multiplication
  "Test multiplication operation"
  (fiveam:is (= 6 (* 2 3)))
  (fiveam:is (= 0 (* 0 100)))
  (fiveam:is (= 100 (* 10 10))))

;;; List operation tests
(fiveam:test list-operations
  "Test basic list operations"
  (fiveam:is (equal '(1 2 3) (cons 1 '(2 3))))
  (fiveam:is (= 1 (car '(1 2 3))))
  (fiveam:is (equal '(2 3) (cdr '(1 2 3))))
  (fiveam:is (= 3 (length '(a b c)))))

;;; Function tests
(defun factorial (n)
  "Calculate factorial"
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(fiveam:test factorial-test
  "Test factorial function"
  (fiveam:is (= 1 (factorial 0)))
  (fiveam:is (= 1 (factorial 1)))
  (fiveam:is (= 120 (factorial 5)))
  (fiveam:is (= 3628800 (factorial 10))))

;;; String tests
(fiveam:test string-operations
  "Test string operations"
  (fiveam:is (string= "hello" "hello"))
  (fiveam:is (string= "HELLO" (string-upcase "hello")))
  (fiveam:is (string= "hello" (string-downcase "HELLO"))))

;;; Hash table tests
(fiveam:test hash-table-operations
  "Test hash table operations"
  (let ((ht (make-hash-table :test 'equal)))
    (setf (gethash "key1" ht) "value1")
    (setf (gethash "key2" ht) "value2")
    (fiveam:is (string= "value1" (gethash "key1" ht)))
    (fiveam:is (string= "value2" (gethash "key2" ht)))
    (fiveam:is (null (gethash "key3" ht)))))

;;; Run all tests
(format t "~%To run tests, evaluate:~%")
(format t "  (fiveam:run! 'basic-tests)~%~%")

|#

;; Simple inline tests (work without FiveAM)
(format t "=== INLINE TESTS (No FiveAM required) ===~%~%")

(defun simple-test (name condition)
  "Simple test function"
  (format t "~a: ~a~%" 
          name 
          (if condition "[PASS]" "[FAIL]")))

;; Arithmetic tests
(format t "Arithmetic Tests:~%")
(simple-test "2 + 2 = 4" (= 4 (+ 2 2)))
(simple-test "5 - 3 = 2" (= 2 (- 5 3)))
(simple-test "3 * 4 = 12" (= 12 (* 3 4)))
(simple-test "10 / 2 = 5" (= 5 (/ 10 2)))

;; List tests
(format t "~%List Tests:~%")
(simple-test "car of (1 2 3) = 1" (= 1 (car '(1 2 3))))
(simple-test "cdr of (1 2 3) = (2 3)" (equal '(2 3) (cdr '(1 2 3))))
(simple-test "length of (a b c) = 3" (= 3 (length '(a b c))))

;; Function tests
(defun my-factorial (n)
  "Calculate factorial"
  (if (<= n 1) 1 (* n (my-factorial (- n 1)))))

(format t "~%Function Tests:~%")
(simple-test "factorial(5) = 120" (= 120 (my-factorial 5)))
(simple-test "factorial(0) = 1" (= 1 (my-factorial 0)))

;; Higher-order function tests
(format t "~%Higher-Order Function Tests:~%")
(simple-test "mapcar double (1 2 3) = (2 4 6)" 
             (equal '(2 4 6) (mapcar (lambda (x) (* 2 x)) '(1 2 3))))
(simple-test "reduce + (1 2 3 4) = 10" 
             (= 10 (reduce #'+ '(1 2 3 4))))

(format t "~%All inline tests completed!~%")

(format t "~%=== TESTING BEST PRACTICES ===~%~%")
(format t "1. Test edge cases (empty lists, zero, negative numbers)~%")
(format t "2. Test normal cases~%")
(format t "3. Test boundary conditions~%")
(format t "4. Use descriptive test names~%")
(format t "5. Keep tests simple and focused~%")
(format t "6. Test one thing per test~%")
(format t "7. Make tests repeatable~%")
(format t "8. Run tests frequently~%")

(format t "~%=== RECOMMENDED TESTING FRAMEWORKS ===~%~%")
(format t "- FiveAM: Popular and feature-rich~%")
(format t "- Prove: Modern testing framework~%")
(format t "- Lisp-Unit: Simple and straightforward~%")
(format t "- RT (Regression Test): Classic framework~%")
