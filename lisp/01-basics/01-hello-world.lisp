;;;; 01-hello-world.lisp
;;;; Introduction to Lisp - Your first program
;;;;
;;;; This is the traditional "Hello, World!" program in Common Lisp.
;;;; It demonstrates basic output and the structure of a simple Lisp program.

;;; Print a simple greeting
(format t "Hello, World!~%")

;;; The format function is Lisp's powerful output function
;;; t means output to standard output
;;; ~% is a newline directive

;;; You can also use print
(print "Hello from Lisp!")

;;; Or write for simpler output
(write-line "Welcome to Common Lisp!")

;;; Multiple lines
(format t "~%Learning Lisp is:~%")
(format t "  - Fun~%")
(format t "  - Powerful~%")
(format t "  - Expressive~%")
