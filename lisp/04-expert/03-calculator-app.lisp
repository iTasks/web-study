;;;; 03-calculator-app.lisp
;;;; Advanced calculator with expression parsing and evaluation
;;;;
;;;; This demonstrates building a complete calculator application.

(format t "=== ADVANCED CALCULATOR APPLICATION ===~%~%")

;;; Define calculator package
(defpackage :calculator
  (:use :common-lisp)
  (:export :parse-expression :evaluate :calculate))

(in-package :calculator)

;;; Token types
(defstruct token
  type    ; :number, :operator, :lparen, :rparen
  value)

;;; Tokenize input string
(defun tokenize (input)
  "Convert input string to list of tokens"
  (let ((tokens nil)
        (i 0)
        (len (length input)))
    (loop while (< i len) do
      (let ((ch (char input i)))
        (cond
          ;; Skip whitespace
          ((char= ch #\Space)
           (incf i))
          
          ;; Numbers
          ((digit-char-p ch)
           (let ((num-str ""))
             (loop while (and (< i len)
                            (or (digit-char-p (char input i))
                                (char= (char input i) #\.))) do
               (setf num-str (concatenate 'string num-str 
                                        (string (char input i))))
               (incf i))
             (push (make-token :type :number 
                              :value (read-from-string num-str))
                   tokens)))
          
          ;; Operators
          ((member ch '(#\+ #\- #\* #\/ #\^))
           (push (make-token :type :operator :value ch) tokens)
           (incf i))
          
          ;; Parentheses
          ((char= ch #\()
           (push (make-token :type :lparen :value ch) tokens)
           (incf i))
          
          ((char= ch #\))
           (push (make-token :type :rparen :value ch) tokens)
           (incf i))
          
          (t (error "Unknown character: ~a" ch)))))
    (reverse tokens)))

;;; Operator precedence
(defun precedence (op)
  "Return precedence of operator"
  (case op
    ((#\+ #\-) 1)
    ((#\* #\/) 2)
    (#\^ 3)
    (t 0)))

;;; Parse expression using Shunting Yard algorithm
(defun parse-expression (input)
  "Parse infix expression to postfix (RPN)"
  (let ((tokens (tokenize input))
        (output nil)
        (operator-stack nil))
    
    (dolist (token tokens)
      (case (token-type token)
        (:number
         (push (token-value token) output))
        
        (:operator
         (let ((op (token-value token)))
           (loop while (and operator-stack
                          (not (eq (car operator-stack) #\())
                          (>= (precedence (car operator-stack))
                              (precedence op)))
                 do (push (pop operator-stack) output))
           (push op operator-stack)))
        
        (:lparen
         (push (token-value token) operator-stack))
        
        (:rparen
         (loop while (and operator-stack
                         (not (eq (car operator-stack) #\()))
               do (push (pop operator-stack) output))
         (when operator-stack
           (pop operator-stack)))))  ; Remove the (
    
    ;; Pop remaining operators
    (loop while operator-stack
          do (push (pop operator-stack) output))
    
    (reverse output)))

;;; Evaluate postfix expression
(defun evaluate (postfix)
  "Evaluate postfix (RPN) expression"
  (let ((stack nil))
    (dolist (item postfix)
      (if (numberp item)
          (push item stack)
          (let ((b (pop stack))
                (a (pop stack)))
            (push (case item
                    (#\+ (+ a b))
                    (#\- (- a b))
                    (#\* (* a b))
                    (#\/ (/ a b))
                    (#\^ (expt a b)))
                  stack))))
    (car stack)))

;;; Convenience function
(defun calculate (expression)
  "Parse and evaluate expression"
  (evaluate (parse-expression expression)))

(in-package :common-lisp-user)

(format t "Calculator Examples:~%~%")

;;; Basic arithmetic
(format t "Basic Arithmetic:~%")
(format t "  2 + 3 = ~a~%" (calculator:calculate "2 + 3"))
(format t "  10 - 4 = ~a~%" (calculator:calculate "10 - 4"))
(format t "  6 * 7 = ~a~%" (calculator:calculate "6 * 7"))
(format t "  20 / 4 = ~a~%" (calculator:calculate "20 / 4"))

;;; Order of operations
(format t "~%Order of Operations:~%")
(format t "  2 + 3 * 4 = ~a~%" (calculator:calculate "2 + 3 * 4"))
(format t "  (2 + 3) * 4 = ~a~%" (calculator:calculate "(2 + 3) * 4"))
(format t "  10 - 2 * 3 = ~a~%" (calculator:calculate "10 - 2 * 3"))

;;; Exponentiation
(format t "~%Exponentiation:~%")
(format t "  2 ^ 3 = ~a~%" (calculator:calculate "2 ^ 3"))
(format t "  2 ^ 3 ^ 2 = ~a~%" (calculator:calculate "2 ^ 3 ^ 2"))
(format t "  (2 ^ 3) ^ 2 = ~a~%" (calculator:calculate "(2 ^ 3) ^ 2"))

;;; Complex expressions
(format t "~%Complex Expressions:~%")
(format t "  (1 + 2) * (3 + 4) = ~a~%" 
        (calculator:calculate "(1 + 2) * (3 + 4)"))
(format t "  ((2 + 3) * 4 - 5) / 3 = ~a~%" 
        (calculator:calculate "((2 + 3) * 4 - 5) / 3"))
(format t "  2 + 3 * 4 - 5 / 2 = ~a~%" 
        (calculator:calculate "2 + 3 * 4 - 5 / 2"))

;;; Decimal numbers
(format t "~%Decimal Numbers:~%")
(format t "  3.14 * 2 = ~a~%" (calculator:calculate "3.14 * 2"))
(format t "  10.5 + 2.3 = ~a~%" (calculator:calculate "10.5 + 2.3"))
(format t "  100 / 3 = ~a~%" (calculator:calculate "100 / 3"))

;;; Show tokenization
(format t "~%Tokenization Example:~%")
(format t "Expression: '(2 + 3) * 4'~%")
(let ((tokens (calculator::tokenize "(2 + 3) * 4")))
  (format t "Tokens: ~%")
  (dolist (token tokens)
    (format t "  Type: ~a, Value: ~a~%"
            (calculator::token-type token)
            (calculator::token-value token))))

;;; Show parsing (infix to postfix)
(format t "~%Parsing Example (Infix to Postfix):~%")
(let ((expr "2 + 3 * 4"))
  (format t "Infix: ~a~%" expr)
  (format t "Postfix (RPN): ~a~%" (calculator:parse-expression expr))
  (format t "Result: ~a~%" (calculator:calculate expr)))

(format t "~%Features Demonstrated:~%")
(format t "  ✓ Tokenization~%")
(format t "  ✓ Parsing (Shunting Yard algorithm)~%")
(format t "  ✓ Expression evaluation~%")
(format t "  ✓ Operator precedence~%")
(format t "  ✓ Parentheses handling~%")
(format t "  ✓ Support for decimals~%")

;;; Interactive calculator function
(defun calc-repl ()
  "Simple calculator REPL"
  (format t "~%Calculator REPL (type 'quit' to exit)~%")
  (loop
    (format t "~%calc> ")
    (force-output)
    (let ((input (read-line)))
      (cond
        ((string-equal input "quit")
         (format t "Goodbye!~%")
         (return))
        ((string= input "")
         nil)
        (t
         (handler-case
             (format t "= ~a~%" (calculator:calculate input))
           (error (e)
             (format t "Error: ~a~%" e))))))))

(format t "~%To start interactive calculator: (calc-repl)~%")
