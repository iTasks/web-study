;;;; 04-pattern-matcher.lisp
;;;; Advanced pattern matching system
;;;;
;;;; This demonstrates a powerful pattern matching system for Lisp.

(format t "=== ADVANCED PATTERN MATCHING SYSTEM ===~%~%")

(defpackage :pattern-matcher
  (:use :common-lisp)
  (:export :match :defpattern :?))

(in-package :pattern-matcher)

;;; Pattern variable marker
(defun pattern-var-p (x)
  "Check if x is a pattern variable (starts with ?)"
  (and (symbolp x)
       (> (length (symbol-name x)) 0)
       (char= (char (symbol-name x) 0) #\?)))

;;; Match a pattern against an expression
(defun match (pattern expression &optional (bindings nil))
  "Match pattern against expression, return bindings or nil"
  (cond
    ;; Pattern variable
    ((pattern-var-p pattern)
     (let ((binding (assoc pattern bindings)))
       (if binding
           ;; Variable already bound, check consistency
           (if (equal (cdr binding) expression)
               bindings
               nil)
           ;; New binding
           (cons (cons pattern expression) bindings))))
    
    ;; Exact match required
    ((atom pattern)
     (if (eql pattern expression)
         bindings
         nil))
    
    ;; Both are lists
    ((and (listp pattern) (listp expression))
     (let ((match-car (match (car pattern) (car expression) bindings)))
       (when match-car
         (match (cdr pattern) (cdr expression) match-car))))
    
    ;; No match
    (t nil)))

;;; Pattern-based function definition
(defmacro defpattern (name &rest clauses)
  "Define a function with pattern matching"
  `(defun ,name (expr)
     (cond
       ,@(mapcar (lambda (clause)
                   (let ((pattern (car clause))
                         (body (cdr clause)))
                     `((match ',pattern expr)
                       (let ,(mapcar (lambda (var)
                                     `(,var (cdr (assoc ',var (match ',pattern expr)))))
                              (find-pattern-vars pattern))
                         ,@body))))
                 clauses)
       (t (error "No pattern matched for ~a" expr)))))

;;; Find all pattern variables in a pattern
(defun find-pattern-vars (pattern)
  "Find all pattern variables in pattern"
  (cond
    ((pattern-var-p pattern) (list pattern))
    ((atom pattern) nil)
    (t (append (find-pattern-vars (car pattern))
               (find-pattern-vars (cdr pattern))))))

(in-package :common-lisp-user)

(format t "Pattern Matching Examples:~%~%")

;;; Example 1: Simple matching
(format t "Example 1: Simple Pattern Matching~%")

(let ((pattern '(+ ?x ?y))
      (expr '(+ 2 3)))
  (format t "Pattern: ~a~%" pattern)
  (format t "Expression: ~a~%" expr)
  (format t "Match: ~a~%~%" (pattern-matcher:match pattern expr)))

;;; Example 2: Nested patterns
(format t "Example 2: Nested Pattern Matching~%")

(let ((pattern '(+ (* ?x ?y) ?z))
      (expr '(+ (* 2 3) 4)))
  (format t "Pattern: ~a~%" pattern)
  (format t "Expression: ~a~%" expr)
  (format t "Match: ~a~%~%" (pattern-matcher:match pattern expr)))

;;; Example 3: Variable consistency
(format t "Example 3: Variable Consistency Check~%")

(let ((pattern '(+ ?x ?x)))  ; Same variable appears twice
  (format t "Pattern: ~a (same variable twice)~%" pattern)
  (format t "  Against (+ 2 2): ~a~%" 
          (pattern-matcher:match pattern '(+ 2 2)))
  (format t "  Against (+ 2 3): ~a~%~%" 
          (pattern-matcher:match pattern '(+ 2 3))))

;;; Example 4: Complex nested matching
(format t "Example 4: Complex Nested Matching~%")

(let ((pattern '(defun ?name (?arg) ?body))
      (expr '(defun square (x) (* x x))))
  (format t "Pattern: ~a~%" pattern)
  (format t "Expression: ~a~%" expr)
  (let ((bindings (pattern-matcher:match pattern expr)))
    (format t "Bindings:~%")
    (dolist (binding bindings)
      (format t "  ~a = ~a~%" (car binding) (cdr binding))))
  (format t "~%"))

;;; Example 5: List pattern matching
(format t "Example 5: List Pattern Matching~%")

(let ((pattern '(?op ?a ?b))
      (exprs '((+ 1 2) (* 3 4) (/ 10 5))))
  (format t "Pattern: ~a~%~%" pattern)
  (dolist (expr exprs)
    (let ((bindings (pattern-matcher:match pattern expr)))
      (format t "Expression: ~a~%" expr)
      (format t "  Operator: ~a, A: ~a, B: ~a~%~%"
              (cdr (assoc '?op bindings))
              (cdr (assoc '?a bindings))
              (cdr (assoc '?b bindings))))))

;;; Example 6: Pattern-based transformation
(format t "Example 6: Pattern-Based Transformation~%")

(defun simplify-expr (expr)
  "Simplify algebraic expressions using pattern matching"
  (let* ((pattern-0-plus '(+ 0 ?x))
         (pattern-plus-0 '(+ ?x 0))
         (pattern-0-times '(* 0 ?x))
         (pattern-times-0 '(* ?x 0))
         (pattern-1-times '(* 1 ?x))
         (pattern-times-1 '(* ?x 1)))
    (cond
      ;; 0 + x = x
      ((pattern-matcher:match pattern-0-plus expr)
       (cdr (assoc '?x (pattern-matcher:match pattern-0-plus expr))))
      
      ;; x + 0 = x
      ((pattern-matcher:match pattern-plus-0 expr)
       (cdr (assoc '?x (pattern-matcher:match pattern-plus-0 expr))))
      
      ;; 0 * x = 0
      ((pattern-matcher:match pattern-0-times expr)
       0)
      
      ;; x * 0 = 0
      ((pattern-matcher:match pattern-times-0 expr)
       0)
      
      ;; 1 * x = x
      ((pattern-matcher:match pattern-1-times expr)
       (cdr (assoc '?x (pattern-matcher:match pattern-1-times expr))))
      
      ;; x * 1 = x
      ((pattern-matcher:match pattern-times-1 expr)
       (cdr (assoc '?x (pattern-matcher:match pattern-times-1 expr))))
      
      ;; No simplification
      (t expr))))

(format t "Simplification examples:~%")
(format t "  (+ 0 x) => ~a~%" (simplify-expr '(+ 0 x)))
(format t "  (+ x 0) => ~a~%" (simplify-expr '(+ x 0)))
(format t "  (* 0 x) => ~a~%" (simplify-expr '(* 0 x)))
(format t "  (* x 0) => ~a~%" (simplify-expr '(* x 0)))
(format t "  (* 1 x) => ~a~%" (simplify-expr '(* 1 x)))
(format t "  (* x 1) => ~a~%~%" (simplify-expr '(* x 1)))

;;; Example 7: Destructuring with patterns
(format t "Example 7: Extracting Information with Patterns~%")

(defun analyze-function-def (expr)
  "Analyze a function definition"
  (let ((pattern '(defun ?name (?params) ?body)))
    (let ((bindings (pattern-matcher:match pattern expr)))
      (when bindings
        (format t "Function Analysis:~%")
        (format t "  Name: ~a~%" (cdr (assoc '?name bindings)))
        (format t "  Parameters: ~a~%" (cdr (assoc '?params bindings)))
        (format t "  Body: ~a~%" (cdr (assoc '?body bindings)))))))

(analyze-function-def '(defun add (x y) (+ x y)))

(format t "~%Features Demonstrated:~%")
(format t "  ✓ Pattern variable binding~%")
(format t "  ✓ Variable consistency checking~%")
(format t "  ✓ Nested pattern matching~%")
(format t "  ✓ Pattern-based transformations~%")
(format t "  ✓ Code analysis~%")

(format t "~%Use Cases:~%")
(format t "  • Compilers and interpreters~%")
(format t "  • Code transformations~%")
(format t "  • Data validation~%")
(format t "  • Rule-based systems~%")
(format t "  • Query languages~%")
