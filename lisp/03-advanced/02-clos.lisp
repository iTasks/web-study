;;;; 02-clos.lisp
;;;; Common Lisp Object System (CLOS)
;;;;
;;;; This file demonstrates object-oriented programming in Common Lisp.

(format t "=== DEFINING CLASSES ===~%")

;;; Define a simple class
(defclass person ()
  ((name
    :initarg :name
    :initform "Unknown"
    :accessor person-name
    :documentation "The person's name")
   (age
    :initarg :age
    :initform 0
    :accessor person-age
    :documentation "The person's age")
   (email
    :initarg :email
    :accessor person-email))
  (:documentation "A simple person class"))

;;; Create instances
(defvar *alice* (make-instance 'person :name "Alice" :age 30))
(defvar *bob* (make-instance 'person :name "Bob" :age 25 :email "bob@example.com"))

(format t "Alice's name: ~a~%" (person-name *alice*))
(format t "Bob's age: ~a~%" (person-age *bob*))

;;; Modify instance
(setf (person-age *alice*) 31)
(format t "Alice's new age: ~a~%" (person-age *alice*))

(format t "~%=== METHODS ===~%")

;;; Define generic function and methods
(defgeneric greet (person)
  (:documentation "Greet a person"))

(defmethod greet ((p person))
  (format t "Hello, my name is ~a~%" (person-name p)))

(greet *alice*)
(greet *bob*)

;;; Method with specialized behavior
(defgeneric describe-person (person)
  (:documentation "Describe a person"))

(defmethod describe-person ((p person))
  (format t "~a is ~a years old~%" (person-name p) (person-age p)))

(describe-person *alice*)
(describe-person *bob*)

(format t "~%=== INHERITANCE ===~%")

;;; Define a subclass
(defclass employee (person)
  ((employee-id
    :initarg :employee-id
    :accessor employee-id)
   (department
    :initarg :department
    :initform "General"
    :accessor employee-department)
   (salary
    :initarg :salary
    :accessor employee-salary))
  (:documentation "An employee is a person with job info"))

(defvar *charlie* (make-instance 'employee
                                 :name "Charlie"
                                 :age 35
                                 :employee-id "E001"
                                 :department "Engineering"
                                 :salary 80000))

(format t "Employee: ~a, ID: ~a, Dept: ~a~%"
        (person-name *charlie*)
        (employee-id *charlie*)
        (employee-department *charlie*))

;;; Override method for subclass
(defmethod greet ((e employee))
  (format t "Hello, I'm ~a from ~a department~%"
          (person-name e)
          (employee-department e)))

(greet *charlie*)

;;; Call next method
(defmethod describe-person ((e employee))
  (call-next-method)  ; Call person's describe-person
  (format t "  Employee ID: ~a, Department: ~a~%"
          (employee-id e)
          (employee-department e)))

(format t "~%")
(describe-person *charlie*)

(format t "~%=== MULTIPLE INHERITANCE ===~%")

;;; Define another class
(defclass student (person)
  ((student-id
    :initarg :student-id
    :accessor student-id)
   (major
    :initarg :major
    :accessor student-major))
  (:documentation "A student"))

;;; Teaching assistant - multiple inheritance
(defclass teaching-assistant (employee student)
  ((course
    :initarg :course
    :accessor ta-course))
  (:documentation "A TA is both employee and student"))

(defvar *dave* (make-instance 'teaching-assistant
                              :name "Dave"
                              :age 28
                              :employee-id "TA001"
                              :student-id "S12345"
                              :major "Computer Science"
                              :course "CS101"))

(format t "TA: ~a, Student ID: ~a, Major: ~a, Course: ~a~%"
        (person-name *dave*)
        (student-id *dave*)
        (student-major *dave*)
        (ta-course *dave*))

(format t "~%=== MULTI-METHODS ===~%")

;;; Methods can specialize on multiple arguments
(defgeneric compatible-p (person1 person2)
  (:documentation "Check if two people are compatible"))

(defmethod compatible-p ((p1 person) (p2 person))
  (format t "~a and ~a might be compatible~%" 
          (person-name p1) (person-name p2))
  t)

(defmethod compatible-p ((e1 employee) (e2 employee))
  (let ((same-dept (equal (employee-department e1) 
                         (employee-department e2))))
    (format t "~a and ~a work in ~a department~%"
            (person-name e1) (person-name e2)
            (if same-dept "the same" "different"))
    same-dept))

(compatible-p *alice* *bob*)
(compatible-p *charlie* (make-instance 'employee 
                                       :name "Eve" 
                                       :department "Engineering"))

(format t "~%=== BEFORE/AFTER/AROUND METHODS ===~%")

(defgeneric work (employee)
  (:documentation "Employee works"))

(defmethod work ((e employee))
  (format t "  ~a is working~%" (person-name e)))

(defmethod work :before ((e employee))
  (format t "BEFORE: ~a clocks in~%" (person-name e)))

(defmethod work :after ((e employee))
  (format t "AFTER: ~a clocks out~%" (person-name e)))

(format t "~%")
(work *charlie*)

(format t "~%=== CLASS SLOTS ===~%")

;;; Class-allocated slot (shared by all instances)
(defclass company ()
  ((company-name
    :initarg :company-name
    :accessor company-name
    :allocation :class
    :initform "ACME Corp")))

(defvar *comp1* (make-instance 'company))
(defvar *comp2* (make-instance 'company))

(format t "Company 1: ~a~%" (company-name *comp1*))
(format t "Company 2: ~a~%" (company-name *comp2*))

(setf (company-name *comp1*) "New Corp")
(format t "After change:~%")
(format t "Company 1: ~a~%" (company-name *comp1*))
(format t "Company 2: ~a~%" (company-name *comp2*))
