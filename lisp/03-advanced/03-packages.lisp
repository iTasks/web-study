;;;; 03-packages.lisp
;;;; Package system in Common Lisp
;;;;
;;;; This file demonstrates the package system for organizing code.

(format t "=== DEFINING PACKAGES ===~%")

;;; Define a package
(defpackage :my-math
  (:documentation "A simple math utilities package")
  (:use :common-lisp)
  (:export :add :multiply :square :cube))

;;; Switch to the package
(in-package :my-math)

(defun add (a b)
  "Add two numbers"
  (+ a b))

(defun multiply (a b)
  "Multiply two numbers"
  (* a b))

(defun square (x)
  "Square a number"
  (* x x))

(defun cube (x)
  "Cube a number"
  (* x x x))

(defun internal-helper (x)
  "Internal function not exported"
  (* 2 x))

;;; Switch back to common-lisp-user
(in-package :common-lisp-user)

(format t "Using my-math package:~%")
(format t "Add 5 + 3 = ~a~%" (my-math:add 5 3))
(format t "Square of 7 = ~a~%" (my-math:square 7))

;;; Import specific symbols
(format t "~%=== IMPORTING SYMBOLS ===~%")

(import 'my-math:multiply)
(format t "Multiply 4 * 6 = ~a~%" (multiply 4 6))

;;; Use-package to import all exported symbols
(defpackage :my-test
  (:use :common-lisp :my-math))

(in-package :my-test)

(format t "~%In my-test package:~%")
(format t "Add 10 + 20 = ~a~%" (add 10 20))
(format t "Cube of 3 = ~a~%" (cube 3))

(in-package :common-lisp-user)

(format t "~%=== PACKAGE WITH NICKNAMES ===~%")

(defpackage :my-utilities
  (:nicknames :my-utils :utils)
  (:use :common-lisp)
  (:export :hello :goodbye))

(in-package :my-utilities)

(defun hello (name)
  (format nil "Hello, ~a!" name))

(defun goodbye (name)
  (format nil "Goodbye, ~a!" name))

(in-package :common-lisp-user)

(format t "Using nicknames:~%")
(format t "~a~%" (utils:hello "World"))
(format t "~a~%" (my-utils:goodbye "World"))

(format t "~%=== PACKAGE CONFLICTS ===~%")

;;; Demonstrate package prefixes to avoid conflicts
(defpackage :lib-a
  (:use :common-lisp)
  (:export :process))

(in-package :lib-a)
(defun process (x)
  (format nil "Lib-A processing: ~a" x))

(defpackage :lib-b
  (:use :common-lisp)
  (:export :process))

(in-package :lib-b)
(defun process (x)
  (format nil "Lib-B processing: ~a" x))

(in-package :common-lisp-user)

(format t "Lib-A: ~a~%" (lib-a:process "data"))
(format t "Lib-B: ~a~%" (lib-b:process "data"))

(format t "~%=== PACKAGE INSPECTION ===~%")

(format t "Current package: ~a~%" *package*)
(format t "Package name: ~a~%" (package-name *package*))

;;; List all packages
(format t "~%Some available packages:~%")
(let ((packages (list-all-packages)))
  (dolist (pkg (subseq packages 0 (min 5 (length packages))))
    (format t "  ~a~%" (package-name pkg))))

(format t "~%=== SYMBOL VISIBILITY ===~%")

(defpackage :visibility-test
  (:use :common-lisp)
  (:export :public-func))

(in-package :visibility-test)

(defun public-func ()
  "This is exported"
  (format nil "Public function"))

(defun private-func ()
  "This is not exported"
  (format nil "Private function"))

(in-package :common-lisp-user)

(format t "Can call public: ~a~%" (visibility-test:public-func))
(format t "Private requires ::~%")
;; This would work but uses internal symbol:
;; (format t "~a~%" (visibility-test::private-func))

(format t "~%=== KEYWORD SYMBOLS ===~%")

;;; Keywords are in their own package
(format t "Keyword package: ~a~%" (symbol-package :my-keyword))
(format t "Keyword value: ~a~%" :test)
(format t "Keywords evaluate to themselves: ~a~%" (eq :test :test))

(format t "~%=== BEST PRACTICES ===~%")
(format t "1. Use packages to organize related functionality~%")
(format t "2. Export only public API~%")
(format t "3. Use nicknames for convenience~%")
(format t "4. Avoid USE-ing many packages (conflicts)~%")
(format t "5. Prefix package name for clarity~%")
