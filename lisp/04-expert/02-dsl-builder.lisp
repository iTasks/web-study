;;;; 02-dsl-builder.lisp
;;;; Domain-Specific Language (DSL) builder
;;;;
;;;; This demonstrates creating a DSL for HTML generation.

(format t "=== DOMAIN-SPECIFIC LANGUAGE BUILDER ===~%~%")

;;; Define a package for HTML DSL
(defpackage :html-dsl
  (:use :common-lisp)
  (:export :html :head :title :body :h1 :h2 :p :div :span
           :a :ul :ol :li :table :tr :td :th
           :render))

(in-package :html-dsl)

;;; HTML element structure
(defstruct html-element
  tag
  attributes
  children)

;;; Macro to create HTML element constructor
(defmacro define-html-tag (name)
  "Define a function for creating HTML element"
  `(defun ,name (&rest args)
     (let ((attributes nil)
           (children nil))
       ;; Parse attributes (keywords) and children
       (dolist (arg args)
         (if (keywordp arg)
             (progn
               (push arg attributes)
               (push (pop args) attributes))
             (push arg children)))
       (make-html-element
        :tag ,(string-downcase (symbol-name name))
        :attributes (reverse attributes)
        :children (reverse children)))))

;;; Define common HTML tags
(define-html-tag html)
(define-html-tag head)
(define-html-tag title)
(define-html-tag body)
(define-html-tag h1)
(define-html-tag h2)
(define-html-tag h3)
(define-html-tag p)
(define-html-tag div)
(define-html-tag span)
(define-html-tag a)
(define-html-tag ul)
(define-html-tag ol)
(define-html-tag li)
(define-html-tag table)
(define-html-tag tr)
(define-html-tag td)
(define-html-tag th)

;;; Render attributes
(defun render-attributes (attributes)
  "Render HTML attributes"
  (when attributes
    (format nil "~{ ~a='~a'~}"
            (loop for (key value) on attributes by #'cddr
                  collect (string-downcase (symbol-name key))
                  collect value))))

;;; Render HTML element
(defun render (element &optional (indent 0))
  "Render HTML element to string"
  (cond
    ;; String content
    ((stringp element)
     (format nil "~v@T~a~%" indent element))
    
    ;; HTML element
    ((html-element-p element)
     (let ((tag (html-element-tag element))
           (attrs (html-element-attributes element))
           (children (html-element-children element)))
       (if children
           ;; Element with children
           (format nil "~v@T<~a~a>~%~{~a~}~v@T</~a>~%"
                   indent
                   tag
                   (render-attributes attrs)
                   (mapcar (lambda (child) (render child (+ indent 2)))
                           children)
                   indent
                   tag)
           ;; Self-closing or empty element
           (format nil "~v@T<~a~a />~%" indent tag (render-attributes attrs)))))
    
    ;; Default
    (t (format nil "~v@T~a~%" indent element))))

(in-package :common-lisp-user)

(format t "HTML DSL Examples:~%~%")

;;; Example 1: Simple page
(format t "Example 1: Simple HTML Page~%")
(format t "~a~%" 
        (html-dsl:render
         (html-dsl:html
          (html-dsl:head
           (html-dsl:title "My Page"))
          (html-dsl:body
           (html-dsl:h1 "Welcome")
           (html-dsl:p "This is a paragraph.")
           (html-dsl:p "Another paragraph.")))))

;;; Example 2: With attributes
(format t "~%Example 2: Elements with Attributes~%")
(format t "~a~%"
        (html-dsl:render
         (html-dsl:div :class "container" :id "main"
          (html-dsl:h1 "Hello, World!")
          (html-dsl:p :style "color: blue;" "Styled paragraph")
          (html-dsl:a :href "https://lisp-lang.org" "Lisp Homepage"))))

;;; Example 3: Lists
(format t "~%Example 3: Lists~%")
(format t "~a~%"
        (html-dsl:render
         (html-dsl:div
          (html-dsl:h2 "My Favorite Languages")
          (html-dsl:ul
           (html-dsl:li "Common Lisp")
           (html-dsl:li "Scheme")
           (html-dsl:li "Racket")))))

;;; Example 4: Table
(format t "~%Example 4: Table~%")
(format t "~a~%"
        (html-dsl:render
         (html-dsl:table :border "1"
          (html-dsl:tr
           (html-dsl:th "Name")
           (html-dsl:th "Age"))
          (html-dsl:tr
           (html-dsl:td "Alice")
           (html-dsl:td "30"))
          (html-dsl:tr
           (html-dsl:td "Bob")
           (html-dsl:td "25")))))

;;; Example 5: Nested structure
(format t "~%Example 5: Complex Nested Structure~%")
(format t "~a~%"
        (html-dsl:render
         (html-dsl:html
          (html-dsl:head
           (html-dsl:title "Dashboard"))
          (html-dsl:body
           (html-dsl:div :class "header"
            (html-dsl:h1 "Dashboard"))
           (html-dsl:div :class "content"
            (html-dsl:div :class "section"
             (html-dsl:h2 "Statistics")
             (html-dsl:p "Users: 1,234"))
            (html-dsl:div :class "section"
             (html-dsl:h2 "Recent Activity")
             (html-dsl:ul
              (html-dsl:li "User logged in")
              (html-dsl:li "New post created"))))))))

(format t "~%DSL Benefits:~%")
(format t "  ✓ Type safety (compile-time checking)~%")
(format t "  ✓ Code completion in editor~%")
(format t "  ✓ Composability~%")
(format t "  ✓ Programmatic generation~%")
(format t "  ✓ No string concatenation~%")
