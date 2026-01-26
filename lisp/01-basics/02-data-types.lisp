;;;; 02-data-types.lisp
;;;; Introduction to Common Lisp data types
;;;;
;;;; This file demonstrates the basic data types available in Common Lisp.

;;; Numbers
(format t "~%=== NUMBERS ===~%")

;; Integers
(format t "Integer: ~a~%" 42)
(format t "Negative: ~a~%" -17)
(format t "Large number: ~a~%" 1000000000)

;; Floating point
(format t "Float: ~a~%" 3.14159)
(format t "Scientific notation: ~a~%" 1.23e-4)

;; Ratios (exact fractions)
(format t "Ratio: ~a~%" 22/7)
(format t "Ratio simplified: ~a~%" 4/2)

;; Complex numbers
(format t "Complex: ~a~%" #C(3 4))

;;; Strings
(format t "~%=== STRINGS ===~%")
(format t "String: ~a~%" "Hello, Lisp!")
(format t "String with quotes: ~a~%" "She said \"Hi\"")
(format t "Concatenation: ~a~%" (concatenate 'string "Hello" " " "World"))

;;; Characters
(format t "~%=== CHARACTERS ===~%")
(format t "Character: ~a~%" #\A)
(format t "Special char: ~a~%" #\Space)
(format t "Newline char: ~a~%" #\Newline)

;;; Symbols
(format t "~%=== SYMBOLS ===~%")
(format t "Symbol: ~a~%" 'hello)
(format t "Symbol: ~a~%" 'this-is-a-symbol)

;;; Boolean values
(format t "~%=== BOOLEANS ===~%")
(format t "True: ~a~%" t)
(format t "False (nil): ~a~%" nil)

;;; Lists
(format t "~%=== LISTS ===~%")
(format t "Empty list: ~a~%" '())
(format t "List of numbers: ~a~%" '(1 2 3 4 5))
(format t "Mixed list: ~a~%" '(1 "hello" 3.14 symbol))
(format t "Nested list: ~a~%" '(1 (2 3) (4 (5 6))))

;;; Arrays
(format t "~%=== ARRAYS ===~%")
(format t "Vector: ~a~%" #(1 2 3 4 5))
(format t "String is array: ~a~%" (arrayp "hello"))
