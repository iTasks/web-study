;;;; lisp-study.asd
;;;; ASDF System Definition for Lisp Study Materials
;;;;
;;;; This file defines the system structure for the Lisp learning materials.
;;;; It allows you to load all examples and tests using ASDF/Quicklisp.

(asdf:defsystem #:lisp-study
  :description "Comprehensive Common Lisp learning materials from zero to expert"
  :author "web-study contributors"
  :license "Educational"
  :version "1.0.0"
  :serial t
  :components ((:module "01-basics"
                :components ((:file "01-hello-world")
                             (:file "02-data-types")
                             (:file "03-variables")
                             (:file "04-control-flow")
                             (:file "05-list-operations")))
               
               (:module "02-intermediate"
                :components ((:file "01-functions")
                             (:file "02-recursion")
                             (:file "03-higher-order-functions")
                             (:file "04-file-io")
                             (:file "05-data-structures")))
               
               (:module "03-advanced"
                :components ((:file "01-macros")
                             (:file "02-clos")
                             (:file "03-packages")
                             (:file "04-optimization")
                             (:file "05-symbolic-computation")))
               
               (:module "04-expert"
                :components ((:file "01-web-server")
                             (:file "02-dsl-builder")
                             (:file "03-calculator-app")
                             (:file "04-pattern-matcher")
                             (:file "05-interpreter")))))

(asdf:defsystem #:lisp-study/tests
  :description "Tests for Lisp Study Materials"
  :author "web-study contributors"
  :license "Educational"
  :version "1.0.0"
  :depends-on (#:lisp-study
               #:fiveam)
  :serial t
  :components ((:module "tests"
                :components ((:file "example-tests"))))
  :perform (asdf:test-op (op c)
             (uiop:symbol-call :fiveam '#:run! 
                              (uiop:find-symbol* '#:basic-tests 
                                                :fiveam))))

;; Usage:
;;
;; To load the entire learning system:
;;   (asdf:load-system :lisp-study)
;;
;; To load and run tests:
;;   (asdf:test-system :lisp-study/tests)
;;
;; In Quicklisp:
;;   (ql:quickload :lisp-study)
;;   (ql:quickload :lisp-study/tests)
