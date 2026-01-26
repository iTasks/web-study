;;;; macros.lisp
;;;; Demonstrates Lisp's powerful macro system
;;;; Macros allow code generation and metaprogramming

;;; ============================================================================
;;; Simple Macros
;;; ============================================================================

(defmacro when-positive (number &body body)
  "Execute body only when number is positive."
  `(when (> ,number 0)
     ,@body))

(defmacro unless-zero (number &body body)
  "Execute body unless number is zero."
  `(unless (zerop ,number)
     ,@body))

;;; ============================================================================
;;; Utility Macros
;;; ============================================================================

(defmacro with-timing (&body body)
  "Measure execution time of body."
  (let ((start (gensym))
        (end (gensym)))
    `(let ((,start (get-internal-real-time)))
       ,@body
       (let ((,end (get-internal-real-time)))
         (format t "Execution time: ~,3f seconds~%"
                 (/ (- ,end ,start) internal-time-units-per-second))))))

(defmacro repeat (n &body body)
  "Repeat body n times."
  `(loop repeat ,n do ,@body))

;;; ============================================================================
;;; Domain-Specific Language (DSL) Example
;;; ============================================================================

(defmacro defpoint (name x y)
  "Define a point with accessor functions."
  `(progn
     (defparameter ,name (cons ,x ,y))
     (defun ,(intern (format nil "~a-X" name)) ()
       (car ,name))
     (defun ,(intern (format nil "~a-Y" name)) ()
       (cdr ,name))))

;;; ============================================================================
;;; Control Flow Macros
;;; ============================================================================

(defmacro while (condition &body body)
  "While loop macro."
  `(loop while ,condition do ,@body))

(defmacro until (condition &body body)
  "Until loop macro."
  `(loop until ,condition do ,@body))

(defmacro for-range ((var start end) &body body)
  "For loop over a range."
  `(loop for ,var from ,start to ,end do ,@body))

;;; ============================================================================
;;; Anaphoric Macros (macros that capture variables)
;;; ============================================================================

(defmacro aif (test then &optional else)
  "Anaphoric if - binds result of test to 'it'."
  `(let ((it ,test))
     (if it ,then ,else)))

(defmacro awhen (test &body body)
  "Anaphoric when - binds result of test to 'it'."
  `(let ((it ,test))
     (when it ,@body)))

;;; ============================================================================
;;; Debugging Macros
;;; ============================================================================

(defmacro debug-print (form)
  "Print form and its result."
  `(let ((result ,form))
     (format t "~a => ~a~%" ',form result)
     result))

(defmacro with-logging (name &body body)
  "Log entry and exit of a code block."
  `(progn
     (format t "Entering ~a~%" ,name)
     (let ((result (progn ,@body)))
       (format t "Exiting ~a~%" ,name)
       result)))

;;; ============================================================================
;;; Demonstrations
;;; ============================================================================

(defun demo-simple-macros ()
  "Demonstrate simple macros."
  (format t "=== Simple Macros ===~%")
  
  (when-positive 5
    (format t "5 is positive~%"))
  
  (unless-zero 10
    (format t "10 is not zero~%"))
  
  (repeat 3
    (format t "Hello! ")))

(defun demo-timing ()
  "Demonstrate timing macro."
  (format t "~%~%=== Timing Macro ===~%")
  (with-timing
    (format t "Calculating factorial of 10000...~%")
    (factorial-iterative 10000)
    (format t "Done!~%")))

(defun factorial-iterative (n)
  "Calculate factorial iteratively."
  (loop for i from 1 to n
        for result = 1 then (* result i)
        finally (return result)))

(defun demo-control-flow ()
  "Demonstrate control flow macros."
  (format t "~%~%=== Control Flow Macros ===~%")
  
  (format t "Counting with for-range:~%")
  (for-range (i 1 5)
    (format t "~a " i))
  (format t "~%")
  
  (format t "While loop:~%")
  (let ((x 0))
    (while (< x 3)
      (format t "x = ~a~%" x)
      (incf x))))

(defun demo-anaphoric ()
  "Demonstrate anaphoric macros."
  (format t "~%~%=== Anaphoric Macros ===~%")
  
  (aif (+ 2 3)
       (format t "Result is ~a~%" it)
       (format t "No result~%"))
  
  (awhen (find 3 '(1 2 3 4 5))
    (format t "Found ~a in list~%" it)))

(defun demo-debugging ()
  "Demonstrate debugging macros."
  (format t "~%~%=== Debugging Macros ===~%")
  
  (debug-print (+ 2 3))
  (debug-print (* 4 5))
  
  (with-logging "calculation"
    (+ 10 20)))

(defun demo-macroexpansion ()
  "Show macro expansion."
  (format t "~%~%=== Macro Expansion ===~%")
  (format t "Original macro call: (when-positive x (print x))~%")
  (format t "Expands to: ~s~%"
          (macroexpand-1 '(when-positive x (print x)))))

;;; ============================================================================
;;; Main Demo
;;; ============================================================================

(defun demo ()
  "Run all macro demonstrations."
  (demo-simple-macros)
  (demo-timing)
  (demo-control-flow)
  (demo-anaphoric)
  (demo-debugging)
  (demo-macroexpansion))

;;; Run demo
(demo)
