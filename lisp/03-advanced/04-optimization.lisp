;;;; 04-optimization.lisp
;;;; Performance optimization in Common Lisp
;;;;
;;;; This file demonstrates various optimization techniques.

(format t "=== TYPE DECLARATIONS ===~%")

;;; Function without type declarations
(defun slow-add (a b)
  (+ a b))

;;; Function with type declarations
(defun fast-add (a b)
  (declare (type fixnum a b))
  (the fixnum (+ a b)))

(format t "Type declarations improve performance~%")
(format t "Fast-add: ~a~%" (fast-add 10 20))

;;; Optimized vector sum
(defun sum-vector (vec)
  "Sum elements of a vector with optimization"
  (declare (type (simple-array fixnum (*)) vec)
           (optimize (speed 3) (safety 0)))
  (let ((sum 0))
    (declare (type fixnum sum))
    (dotimes (i (length vec))
      (incf sum (aref vec i)))
    sum))

(defvar *test-vec* (make-array 5 :element-type 'fixnum 
                               :initial-contents '(1 2 3 4 5)))
(format t "Sum of vector: ~a~%" (sum-vector *test-vec*))

(format t "~%=== TAIL RECURSION ===~%")

;;; Non-tail-recursive factorial (uses stack)
(defun factorial-slow (n)
  (if (<= n 1)
      1
      (* n (factorial-slow (- n 1)))))

;;; Tail-recursive factorial (can be optimized)
(defun factorial-fast (n &optional (acc 1))
  (declare (optimize (speed 3) (debug 0)))
  (if (<= n 1)
      acc
      (factorial-fast (- n 1) (* n acc))))

(format t "Slow factorial of 10: ~a~%" (factorial-slow 10))
(format t "Fast factorial of 10: ~a~%" (factorial-fast 10))
(format t "Fast factorial of 100: ~a~%" (factorial-fast 100))

(format t "~%=== INLINE FUNCTIONS ===~%")

;;; Declare function as inline
(declaim (inline square-inline))
(defun square-inline (x)
  (declare (type fixnum x))
  (* x x))

(defun use-inline (n)
  (declare (type fixnum n)
           (optimize (speed 3)))
  (+ (square-inline n) (square-inline (1+ n))))

(format t "Using inline function: ~a~%" (use-inline 5))

(format t "~%=== LOOP OPTIMIZATION ===~%")

;;; Optimized loop with declarations
(defun count-positive (numbers)
  "Count positive numbers with optimization"
  (declare (type list numbers)
           (optimize (speed 3) (safety 0)))
  (let ((count 0))
    (declare (type fixnum count))
    (dolist (n numbers)
      (declare (type fixnum n))
      (when (> n 0)
        (incf count)))
    count))

(format t "Positive count: ~a~%" 
        (count-positive '(-1 2 -3 4 5 -6 7)))

(format t "~%=== AVOIDING CONSING ===~%")

;;; This creates many cons cells
(defun append-many-slow (n)
  (let ((result nil))
    (dotimes (i n)
      (setf result (append result (list i))))
    result))

;;; This is more efficient
(defun append-many-fast (n)
  (let ((result nil))
    (dotimes (i n)
      (push i result))
    (nreverse result)))

(format t "Fast append created: ~a~%" (append-many-fast 10))

(format t "~%=== DESTRUCTIVE OPERATIONS ===~%")

;;; Non-destructive (creates new list)
(defvar *list1* '(3 1 4 1 5 9))
(format t "Original list: ~a~%" *list1*)
(format t "Sorted (copy): ~a~%" (sort (copy-list *list1*) #'<))
(format t "Original unchanged: ~a~%" *list1*)

;;; Destructive (modifies in place)
(defvar *list2* (list 3 1 4 1 5 9))
(format t "~%List before sort: ~a~%" *list2*)
(setf *list2* (sort *list2* #'<))
(format t "List after sort: ~a~%" *list2*)

(format t "~%=== SPECIALIZED ARRAYS ===~%")

;;; Generic array (can hold any type)
(defvar *generic-array* (make-array 5 :initial-element 0))

;;; Specialized array (only fixnums)
(defvar *fixnum-array* (make-array 5 :element-type 'fixnum 
                                   :initial-element 0))

(format t "Specialized arrays are faster for numeric operations~%")
(format t "Generic array: ~a~%" *generic-array*)
(format t "Fixnum array: ~a~%" *fixnum-array*)

(format t "~%=== COMPILATION ===~%")

(format t "Functions are compiled by default in most implementations~%")
(format t "Use (compile 'function-name) to compile explicitly~%")
(format t "Use (compile nil '(lambda...)) for anonymous functions~%")

(defvar *compiled-fn* (compile nil '(lambda (x) (* x x))))
(format t "Compiled lambda: ~a~%" (funcall *compiled-fn* 7))

(format t "~%=== OPTIMIZATION LEVELS ===~%")

(format t "Optimization declarations:~%")
(format t "  (optimize (speed 3) (safety 0)) - maximum speed~%")
(format t "  (optimize (space 3)) - minimize space~%")
(format t "  (optimize (debug 3)) - maximum debugging info~%")
(format t "  (optimize (compilation-speed 3)) - fast compilation~%")

(format t "~%=== PROFILING (info) ===~%")

(format t "Use implementation-specific profilers:~%")
(format t "  SBCL: (require :sb-sprof) (sb-sprof:with-profiling ...)~%")
(format t "  Time macro: (time (your-function))~%")

;;; Simple timing
(defun time-function (func iterations)
  "Time a function call"
  (let ((start (get-internal-real-time)))
    (dotimes (i iterations)
      (funcall func))
    (let ((end (get-internal-real-time)))
      (format t "Time for ~a iterations: ~,6f seconds~%"
              iterations
              (/ (- end start) internal-time-units-per-second)))))

(format t "~%Timing example:~%")
(time-function (lambda () (factorial-fast 50)) 10000)

(format t "~%=== BEST PRACTICES ===~%")
(format t "1. Profile before optimizing~%")
(format t "2. Use type declarations for numeric code~%")
(format t "3. Use tail recursion for deep recursion~%")
(format t "4. Avoid unnecessary consing~%")
(format t "5. Use specialized arrays for numeric data~%")
(format t "6. Consider destructive operations when safe~%")
(format t "7. Inline small, frequently-called functions~%")
