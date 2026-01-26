;;;; 04-control-flow.lisp
;;;; Control flow structures in Common Lisp
;;;;
;;;; This file demonstrates if, cond, case, and other control structures.

;;; IF statement
(format t "=== IF STATEMENTS ===~%")

(let ((x 10))
  (if (> x 5)
      (format t "x (~a) is greater than 5~%" x)
      (format t "x (~a) is not greater than 5~%" x)))

;;; IF with then and else
(let ((age 20))
  (if (>= age 18)
      (format t "Age ~a: You can vote!~%" age)
      (format t "Age ~a: Too young to vote.~%" age)))

;;; WHEN (if without else)
(format t "~%=== WHEN ===~%")
(let ((score 85))
  (when (>= score 80)
    (format t "Score ~a: Excellent!~%" score)
    (format t "You passed with distinction!~%")))

;;; UNLESS (opposite of when)
(format t "~%=== UNLESS ===~%")
(let ((temperature 15))
  (unless (> temperature 20)
    (format t "Temperature ~a°C: It's cold!~%" temperature)
    (format t "Wear a jacket!~%")))

;;; COND (multiple conditions)
(format t "~%=== COND ===~%")

(defun grade-letter (score)
  "Convert numeric score to letter grade"
  (cond
    ((>= score 90) "A")
    ((>= score 80) "B")
    ((>= score 70) "C")
    ((>= score 60) "D")
    (t "F")))

(format t "Score 95: ~a~%" (grade-letter 95))
(format t "Score 85: ~a~%" (grade-letter 85))
(format t "Score 75: ~a~%" (grade-letter 75))
(format t "Score 55: ~a~%" (grade-letter 55))

;;; CASE (like switch statement)
(format t "~%=== CASE ===~%")

(defun day-name (n)
  "Return the name of the day given a number (1-7)"
  (case n
    (1 "Monday")
    (2 "Tuesday")
    (3 "Wednesday")
    (4 "Thursday")
    (5 "Friday")
    (6 "Saturday")
    (7 "Sunday")
    (otherwise "Invalid day")))

(format t "Day 1: ~a~%" (day-name 1))
(format t "Day 5: ~a~%" (day-name 5))
(format t "Day 7: ~a~%" (day-name 7))
(format t "Day 10: ~a~%" (day-name 10))

;;; AND and OR
(format t "~%=== AND/OR ===~%")

(let ((x 10)
      (y 5))
  (format t "x=~a, y=~a~%" x y)
  (format t "x > 5 AND y > 3: ~a~%" (and (> x 5) (> y 3)))
  (format t "x > 15 OR y > 3: ~a~%" (or (> x 15) (> y 3))))

;;; NOT
(format t "~%=== NOT ===~%")
(format t "NOT true: ~a~%" (not t))
(format t "NOT false: ~a~%" (not nil))
(format t "NOT (5 > 10): ~a~%" (not (> 5 10)))
