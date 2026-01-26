;;;; 05-symbolic-computation.lisp
;;;; Symbolic computation in Common Lisp
;;;;
;;;; This file demonstrates Lisp's strength in symbolic processing.

(format t "=== SYMBOLIC EXPRESSIONS ===~%")

;;; Symbols and symbolic manipulation
(defvar *expr1* '(+ 2 3))
(defvar *expr2* '(* 4 5))
(defvar *expr3* '(+ (* 2 3) (/ 8 4)))

(format t "Expression 1: ~a~%" *expr1*)
(format t "Expression 2: ~a~%" *expr2*)
(format t "Expression 3: ~a~%" *expr3*)

;;; Evaluate symbolic expressions
(format t "~%Evaluation:~%")
(format t "eval ~a = ~a~%" *expr1* (eval *expr1*))
(format t "eval ~a = ~a~%" *expr2* (eval *expr2*))
(format t "eval ~a = ~a~%" *expr3* (eval *expr3*))

(format t "~%=== SYMBOLIC DIFFERENTIATION ===~%")

;;; Simple symbolic differentiation
(defun deriv (expr var)
  "Symbolic differentiation"
  (cond
    ;; d/dx(c) = 0 for constant
    ((numberp expr) 0)
    
    ;; d/dx(x) = 1
    ((eq expr var) 1)
    
    ;; d/dx(y) = 0 for other variables
    ((symbolp expr) 0)
    
    ;; d/dx(u + v) = du/dx + dv/dx
    ((eq (car expr) '+)
     (list '+ (deriv (cadr expr) var)
           (deriv (caddr expr) var)))
    
    ;; d/dx(u - v) = du/dx - dv/dx
    ((eq (car expr) '-)
     (list '- (deriv (cadr expr) var)
           (deriv (caddr expr) var)))
    
    ;; d/dx(u * v) = u * dv/dx + v * du/dx
    ((eq (car expr) '*)
     (list '+ 
           (list '* (cadr expr) (deriv (caddr expr) var))
           (list '* (caddr expr) (deriv (cadr expr) var))))
    
    ;; d/dx(u / v) = (v * du/dx - u * dv/dx) / v^2
    ((eq (car expr) '/)
     (list '/ 
           (list '- 
                 (list '* (caddr expr) (deriv (cadr expr) var))
                 (list '* (cadr expr) (deriv (caddr expr) var)))
           (list '* (caddr expr) (caddr expr))))
    
    (t (error "Unknown expression type"))))

(format t "d/dx (x) = ~a~%" (deriv 'x 'x))
(format t "d/dx (5) = ~a~%" (deriv 5 'x))
(format t "d/dx (x + 3) = ~a~%" (deriv '(+ x 3) 'x))
(format t "d/dx (x * x) = ~a~%" (deriv '(* x x) 'x))
(format t "d/dx (x * y) = ~a~%" (deriv '(* x y) 'x))

(format t "~%=== SYMBOLIC SIMPLIFICATION ===~%")

;;; Simple expression simplification
(defun simplify (expr)
  "Simplify symbolic expression"
  (cond
    ((atom expr) expr)
    
    ;; Simplify addition
    ((eq (car expr) '+)
     (let ((a (simplify (cadr expr)))
           (b (simplify (caddr expr))))
       (cond
         ((and (numberp a) (numberp b)) (+ a b))
         ((equal a 0) b)
         ((equal b 0) a)
         (t (list '+ a b)))))
    
    ;; Simplify multiplication
    ((eq (car expr) '*)
     (let ((a (simplify (cadr expr)))
           (b (simplify (caddr expr))))
       (cond
         ((and (numberp a) (numberp b)) (* a b))
         ((equal a 0) 0)
         ((equal b 0) 0)
         ((equal a 1) b)
         ((equal b 1) a)
         (t (list '* a b)))))
    
    (t expr)))

(format t "Simplify (+ 0 x): ~a~%" (simplify '(+ 0 x)))
(format t "Simplify (* 1 x): ~a~%" (simplify '(* 1 x)))
(format t "Simplify (* 0 x): ~a~%" (simplify '(* 0 x)))
(format t "Simplify (+ 2 3): ~a~%" (simplify '(+ 2 3)))

(format t "~%=== PATTERN MATCHING ===~%")

;;; Simple pattern matcher
(defun match-pattern (pattern expr bindings)
  "Match pattern against expression"
  (cond
    ;; Variable pattern (starts with ?)
    ((and (symbolp pattern)
          (char= (char (symbol-name pattern) 0) #\?))
     (let ((binding (assoc pattern bindings)))
       (if binding
           (if (equal (cdr binding) expr)
               bindings
               nil)
           (cons (cons pattern expr) bindings))))
    
    ;; Exact match
    ((atom pattern)
     (if (equal pattern expr) bindings nil))
    
    ;; Recursive match
    ((and (listp expr) (= (length pattern) (length expr)))
     (match-pattern (cdr pattern) (cdr expr)
                    (match-pattern (car pattern) (car expr) bindings)))
    
    (t nil)))

(format t "Match '(+ ?x ?y) with '(+ 2 3):~%")
(format t "  ~a~%" (match-pattern '(+ ?x ?y) '(+ 2 3) nil))

(format t "Match '(* ?x ?x) with '(* 5 5):~%")
(format t "  ~a~%" (match-pattern '(* ?x ?x) '(* 5 5) nil))

(format t "~%=== SYMBOLIC ALGEBRA ===~%")

;;; Expand polynomial
(defun expand-polynomial (expr)
  "Expand simple polynomial expressions"
  (cond
    ((atom expr) expr)
    
    ;; (a + b)^2 = a^2 + 2ab + b^2
    ((and (eq (car expr) 'expt)
          (listp (cadr expr))
          (eq (caadr expr) '+)
          (= (caddr expr) 2))
     (let* ((sum (cadr expr))
            (a (cadr sum))
            (b (caddr sum)))
       (list '+ 
             (list 'expt a 2)
             (list '* 2 (list '* a b))
             (list 'expt b 2))))
    
    (t expr)))

(format t "Expand (x + y)^2: ~a~%" 
        (expand-polynomial '(expt (+ x y) 2)))

(format t "~%=== SYMBOLIC EVALUATION ===~%")

;;; Substitute variables with values
(defun substitute-vars (expr bindings)
  "Substitute variables in expression"
  (cond
    ((numberp expr) expr)
    ((symbolp expr)
     (let ((binding (assoc expr bindings)))
       (if binding (cdr binding) expr)))
    ((listp expr)
     (cons (car expr)
           (mapcar (lambda (e) (substitute-vars e bindings))
                   (cdr expr))))
    (t expr)))

(defvar *expr* '(+ (* 2 x) y))
(defvar *bindings* '((x . 5) (y . 3)))

(format t "Expression: ~a~%" *expr*)
(format t "With x=5, y=3: ~a~%" 
        (substitute-vars *expr* *bindings*))
(format t "Evaluated: ~a~%" 
        (eval (substitute-vars *expr* *bindings*)))

(format t "~%=== CODE AS DATA ===~%")

;;; Generate code programmatically
(defun make-adder-code (n)
  "Generate code for an adder function"
  `(lambda (x) (+ x ,n)))

(format t "Generated code: ~a~%" (make-adder-code 10))

(defvar *add-10* (eval (make-adder-code 10)))
(format t "Execute generated code: ~a~%" (funcall *add-10* 5))

;;; Build function at runtime
(defun make-operation (op)
  "Create a function for the given operation"
  (eval `(lambda (a b) (,op a b))))

(defvar *my-mult* (make-operation '*))
(format t "~%Dynamic multiplication: ~a~%" (funcall *my-mult* 6 7))
