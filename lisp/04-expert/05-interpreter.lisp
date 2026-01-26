;;;; 05-interpreter.lisp
;;;; Simple Lisp interpreter implementation
;;;;
;;;; This demonstrates building a meta-circular evaluator.

(format t "=== SIMPLE LISP INTERPRETER ===~%~%")

(defpackage :mini-lisp
  (:use :common-lisp)
  (:export :eval-expr :repl))

(in-package :mini-lisp)

;;; Environment representation (association list)
(defvar *global-env* nil
  "Global environment for variable bindings")

;;; Initialize global environment with primitives
(setf *global-env*
      '((+ . :primitive)
        (- . :primitive)
        (* . :primitive)
        (/ . :primitive)
        (< . :primitive)
        (> . :primitive)
        (= . :primitive)
        (eq . :primitive)
        (null . :primitive)
        (car . :primitive)
        (cdr . :primitive)
        (cons . :primitive)
        (list . :primitive)))

;;; Lookup variable in environment
(defun lookup (var env)
  "Look up variable in environment"
  (let ((binding (assoc var env)))
    (if binding
        (cdr binding)
        (error "Unbound variable: ~a" var))))

;;; Extend environment with new bindings
(defun extend-env (vars vals env)
  "Extend environment with variable bindings"
  (append (mapcar #'cons vars vals) env))

;;; Check if expression is self-evaluating
(defun self-evaluating-p (expr)
  "Check if expression evaluates to itself"
  (or (numberp expr)
      (stringp expr)
      (eq expr t)
      (eq expr nil)))

;;; Check if expression is a variable
(defun variable-p (expr)
  "Check if expression is a variable"
  (symbolp expr))

;;; Apply primitive operation
(defun apply-primitive (op args)
  "Apply primitive operation"
  (case op
    (+ (apply #'+ args))
    (- (apply #'- args))
    (* (apply #'* args))
    (/ (apply #'/ args))
    (< (apply #'< args))
    (> (apply #'> args))
    (= (apply #'= args))
    (eq (apply #'eq args))
    (null (null (car args)))
    (car (car (car args)))
    (cdr (cdr (car args)))
    (cons (cons (car args) (cadr args)))
    (list args)
    (t (error "Unknown primitive: ~a" op))))

;;; Evaluate expression
(defun eval-expr (expr &optional (env *global-env*))
  "Evaluate expression in environment"
  (cond
    ;; Self-evaluating
    ((self-evaluating-p expr)
     expr)
    
    ;; Variable
    ((variable-p expr)
     (lookup expr env))
    
    ;; Quote
    ((eq (car expr) 'quote)
     (cadr expr))
    
    ;; If
    ((eq (car expr) 'if)
     (if (eval-expr (cadr expr) env)
         (eval-expr (caddr expr) env)
         (eval-expr (cadddr expr) env)))
    
    ;; Define
    ((eq (car expr) 'define)
     (let ((var (cadr expr))
           (val (eval-expr (caddr expr) env)))
       (setf *global-env* (cons (cons var val) *global-env*))
       var))
    
    ;; Lambda
    ((eq (car expr) 'lambda)
     (let ((params (cadr expr))
           (body (caddr expr)))
       (list :closure params body env)))
    
    ;; Begin (sequence)
    ((eq (car expr) 'begin)
     (let ((result nil))
       (dolist (form (cdr expr) result)
         (setf result (eval-expr form env)))))
    
    ;; Function application
    ((listp expr)
     (let ((op (eval-expr (car expr) env))
           (args (mapcar (lambda (arg) (eval-expr arg env))
                        (cdr expr))))
       (cond
         ;; Primitive operation
         ((eq op :primitive)
          (apply-primitive (car expr) args))
         
         ;; Closure (user-defined function)
         ((and (listp op) (eq (car op) :closure))
          (let ((params (cadr op))
                (body (caddr op))
                (closure-env (cadddr op)))
            (eval-expr body (extend-env params args closure-env))))
         
         (t (error "Not a function: ~a" op)))))
    
    (t (error "Unknown expression type: ~a" expr))))

(in-package :common-lisp-user)

(format t "Interpreter Examples:~%~%")

;;; Example 1: Arithmetic
(format t "Example 1: Arithmetic~%")
(format t "  (+ 2 3) = ~a~%" (mini-lisp:eval-expr '(+ 2 3)))
(format t "  (* 4 5) = ~a~%" (mini-lisp:eval-expr '(* 4 5)))
(format t "  (- 10 3) = ~a~%" (mini-lisp:eval-expr '(- 10 3)))
(format t "  (/ 20 4) = ~a~%~%" (mini-lisp:eval-expr '(/ 20 4)))

;;; Example 2: Nested expressions
(format t "Example 2: Nested Expressions~%")
(format t "  (+ (* 2 3) 4) = ~a~%" 
        (mini-lisp:eval-expr '(+ (* 2 3) 4)))
(format t "  (* (+ 1 2) (+ 3 4)) = ~a~%~%" 
        (mini-lisp:eval-expr '(* (+ 1 2) (+ 3 4))))

;;; Example 3: Quote
(format t "Example 3: Quote~%")
(format t "  (quote (1 2 3)) = ~a~%" 
        (mini-lisp:eval-expr '(quote (1 2 3))))
(format t "  (quote (+ 1 2)) = ~a~%~%" 
        (mini-lisp:eval-expr '(quote (+ 1 2))))

;;; Example 4: If conditionals
(format t "Example 4: Conditionals~%")
(format t "  (if (> 5 3) 'yes 'no) = ~a~%" 
        (mini-lisp:eval-expr '(if (> 5 3) 'yes 'no)))
(format t "  (if (< 5 3) 'yes 'no) = ~a~%~%" 
        (mini-lisp:eval-expr '(if (< 5 3) 'yes 'no)))

;;; Example 5: Define variables
(format t "Example 5: Define Variables~%")
(mini-lisp:eval-expr '(define x 10))
(mini-lisp:eval-expr '(define y 20))
(format t "  After (define x 10) and (define y 20):~%")
(format t "  x = ~a~%" (mini-lisp:eval-expr 'x))
(format t "  y = ~a~%" (mini-lisp:eval-expr 'y))
(format t "  (+ x y) = ~a~%~%" (mini-lisp:eval-expr '(+ x y)))

;;; Example 6: Lambda functions
(format t "Example 6: Lambda Functions~%")
(mini-lisp:eval-expr '(define square (lambda (x) (* x x))))
(format t "  After (define square (lambda (x) (* x x))):~%")
(format t "  (square 5) = ~a~%" (mini-lisp:eval-expr '(square 5)))
(format t "  (square 10) = ~a~%~%" (mini-lisp:eval-expr '(square 10)))

;;; Example 7: Higher-order functions
(format t "Example 7: Higher-Order Functions~%")
(mini-lisp:eval-expr '(define make-adder 
                       (lambda (n) 
                         (lambda (x) (+ x n)))))
(mini-lisp:eval-expr '(define add-10 (make-adder 10)))
(format t "  After defining make-adder and (define add-10 (make-adder 10)):~%")
(format t "  (add-10 5) = ~a~%~%" (mini-lisp:eval-expr '(add-10 5)))

;;; Example 8: List operations
(format t "Example 8: List Operations~%")
(format t "  (list 1 2 3) = ~a~%" 
        (mini-lisp:eval-expr '(list 1 2 3)))
(format t "  (cons 1 (cons 2 (cons 3 (quote ())))) = ~a~%" 
        (mini-lisp:eval-expr '(cons 1 (cons 2 (cons 3 (quote ()))))))
(format t "  (car (quote (1 2 3))) = ~a~%" 
        (mini-lisp:eval-expr '(car (quote (1 2 3)))))
(format t "  (cdr (quote (1 2 3))) = ~a~%~%" 
        (mini-lisp:eval-expr '(cdr (quote (1 2 3)))))

;;; Example 9: Factorial (recursive)
(format t "Example 9: Recursive Factorial~%")
(mini-lisp:eval-expr 
 '(define factorial
    (lambda (n)
      (if (= n 0)
          1
          (* n (factorial (- n 1)))))))
(format t "  (factorial 5) = ~a~%" (mini-lisp:eval-expr '(factorial 5)))
(format t "  (factorial 10) = ~a~%~%" (mini-lisp:eval-expr '(factorial 10)))

;;; Example 10: Begin (sequence)
(format t "Example 10: Begin (Sequence)~%")
(format t "  (begin (define a 5) (define b 10) (+ a b)) = ~a~%~%" 
        (mini-lisp:eval-expr '(begin (define a 5) (define b 10) (+ a b))))

(format t "Features Demonstrated:~%")
(format t "  ✓ Expression evaluation~%")
(format t "  ✓ Variable binding~%")
(format t "  ✓ Lambda (closures)~%")
(format t "  ✓ Conditionals~%")
(format t "  ✓ Recursion~%")
(format t "  ✓ Higher-order functions~%")
(format t "  ✓ List operations~%")

(format t "~%This is a simple meta-circular evaluator!~%")
(format t "It demonstrates how Lisp can evaluate Lisp code.~%")
