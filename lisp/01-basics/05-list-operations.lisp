;;;; 05-list-operations.lisp
;;;; Basic list operations in Common Lisp
;;;;
;;;; Lists are fundamental to Lisp. This file demonstrates basic list operations.

(format t "=== CREATING LISTS ===~%")

;;; Creating lists
(defvar *list1* '(1 2 3 4 5))
(defvar *list2* (list 10 20 30))
(defvar *list3* (cons 1 (cons 2 (cons 3 nil))))

(format t "List 1: ~a~%" *list1*)
(format t "List 2: ~a~%" *list2*)
(format t "List 3: ~a~%" *list3*)

;;; Accessing list elements
(format t "~%=== ACCESSING ELEMENTS ===~%")
(format t "First element (car): ~a~%" (car *list1*))
(format t "Rest (cdr): ~a~%" (cdr *list1*))
(format t "Second element (cadr): ~a~%" (cadr *list1*))
(format t "Third element (caddr): ~a~%" (caddr *list1*))
(format t "Nth element (0-indexed): ~a~%" (nth 2 *list1*))

;;; List properties
(format t "~%=== LIST PROPERTIES ===~%")
(format t "Length: ~a~%" (length *list1*))
(format t "Is null? ~a~%" (null *list1*))
(format t "Is null empty list? ~a~%" (null '()))

;;; Adding elements
(format t "~%=== ADDING ELEMENTS ===~%")
(format t "Cons 0 to front: ~a~%" (cons 0 *list1*))
(format t "Append lists: ~a~%" (append *list1* *list2*))
(format t "List* (similar to cons): ~a~%" (list* 1 2 3 '(4 5)))

;;; Removing elements
(format t "~%=== REMOVING ELEMENTS ===~%")
(format t "Remove 3: ~a~%" (remove 3 *list1*))
(format t "Remove if odd: ~a~%" (remove-if #'oddp *list1*))
(format t "Remove if even: ~a~%" (remove-if-not #'oddp *list1*))

;;; Finding elements
(format t "~%=== FINDING ELEMENTS ===~%")
(format t "Find 3: ~a~%" (find 3 *list1*))
(format t "Find 10: ~a~%" (find 10 *list1*))
(format t "Member 4: ~a~%" (member 4 *list1*))
(format t "Position of 3: ~a~%" (position 3 *list1*))

;;; List transformation
(format t "~%=== TRANSFORMING LISTS ===~%")
(format t "Reverse: ~a~%" (reverse *list1*))
(format t "Sort ascending: ~a~%" (sort (copy-list '(5 2 8 1 9)) #'<))
(format t "Sort descending: ~a~%" (sort (copy-list '(5 2 8 1 9)) #'>))

;;; Nested lists
(format t "~%=== NESTED LISTS ===~%")
(defvar *nested* '((1 2) (3 4) (5 6)))
(format t "Nested list: ~a~%" *nested*)
(format t "First sublist: ~a~%" (car *nested*))
(format t "First of first: ~a~%" (caar *nested*))
