;;;; 05-data-structures.lisp
;;;; Data structures in Common Lisp
;;;;
;;;; This file demonstrates various data structures beyond simple lists.

(format t "=== ASSOCIATION LISTS (ALISTS) ===~%")

;;; Association lists - simple key-value pairs
(defvar *person-alist* 
  '((name . "Alice")
    (age . 30)
    (city . "Boston")
    (occupation . "Engineer")))

(format t "Person: ~a~%" *person-alist*)
(format t "Name: ~a~%" (cdr (assoc 'name *person-alist*)))
(format t "Age: ~a~%" (cdr (assoc 'age *person-alist*)))

;;; Add to alist
(defvar *extended-alist* (acons 'country "USA" *person-alist*))
(format t "Extended: ~a~%" *extended-alist*)

(format t "~%=== PROPERTY LISTS (PLISTS) ===~%")

;;; Property lists - alternating keys and values
(defvar *person-plist* 
  '(:name "Bob" 
    :age 25 
    :city "Seattle" 
    :occupation "Developer"))

(format t "Person: ~a~%" *person-plist*)
(format t "Name: ~a~%" (getf *person-plist* :name))
(format t "City: ~a~%" (getf *person-plist* :city))

;;; Modify plist
(setf (getf *person-plist* :age) 26)
(format t "Updated age: ~a~%" (getf *person-plist* :age))

;;; Add to plist
(setf (getf *person-plist* :country) "USA")
(format t "With country: ~a~%" *person-plist*)

(format t "~%=== HASH TABLES ===~%")

;;; Create hash table
(defvar *person-hash* (make-hash-table :test 'equal))

;;; Add entries
(setf (gethash "name" *person-hash*) "Charlie")
(setf (gethash "age" *person-hash*) 35)
(setf (gethash "city" *person-hash*) "Portland")

(format t "Name: ~a~%" (gethash "name" *person-hash*))
(format t "Age: ~a~%" (gethash "age" *person-hash*))
(format t "City: ~a~%" (gethash "city" *person-hash*))

;;; Check if key exists
(format t "Has occupation? ~a~%" (nth-value 1 (gethash "occupation" *person-hash*)))

;;; Iterate over hash table
(format t "~%All entries:~%")
(maphash (lambda (key value)
           (format t "  ~a: ~a~%" key value))
         *person-hash*)

;;; Hash table with symbols as keys
(defvar *config* (make-hash-table))
(setf (gethash 'debug *config*) t)
(setf (gethash 'port *config*) 8080)
(setf (gethash 'host *config*) "localhost")

(format t "~%Config:~%")
(maphash (lambda (k v) (format t "  ~a: ~a~%" k v)) *config*)

(format t "~%=== ARRAYS ===~%")

;;; One-dimensional array
(defvar *numbers* (make-array 5 :initial-contents '(10 20 30 40 50)))
(format t "Array: ~a~%" *numbers*)
(format t "Element 0: ~a~%" (aref *numbers* 0))
(format t "Element 3: ~a~%" (aref *numbers* 3))

;;; Modify array
(setf (aref *numbers* 2) 99)
(format t "After modification: ~a~%" *numbers*)

;;; Multi-dimensional array
(defvar *matrix* (make-array '(3 3) 
                             :initial-contents '((1 2 3)
                                                (4 5 6)
                                                (7 8 9))))

(format t "~%Matrix [0,0]: ~a~%" (aref *matrix* 0 0))
(format t "Matrix [1,1]: ~a~%" (aref *matrix* 1 1))
(format t "Matrix [2,2]: ~a~%" (aref *matrix* 2 2))

(format t "~%=== STRUCTURES ===~%")

;;; Define a structure
(defstruct person
  name
  age
  city
  (country "USA" :type string))

;;; Create instances
(defvar *alice* (make-person :name "Alice" :age 30 :city "Boston"))
(defvar *bob* (make-person :name "Bob" :age 25 :city "Seattle"))

(format t "Alice: ~a~%" *alice*)
(format t "Alice's name: ~a~%" (person-name *alice*))
(format t "Alice's age: ~a~%" (person-age *alice*))
(format t "Alice's city: ~a~%" (person-city *alice*))

;;; Modify structure
(setf (person-age *alice*) 31)
(format t "Alice's new age: ~a~%" (person-age *alice*))

(format t "~%=== QUEUES (using lists) ===~%")

;;; Simple queue implementation
(defvar *queue* nil)

(defun enqueue (item queue)
  "Add item to end of queue"
  (append queue (list item)))

(defun dequeue (queue)
  "Remove and return first item from queue"
  (values (car queue) (cdr queue)))

(setf *queue* (enqueue 'first *queue*))
(setf *queue* (enqueue 'second *queue*))
(setf *queue* (enqueue 'third *queue*))

(format t "Queue: ~a~%" *queue*)

(multiple-value-bind (item new-queue) (dequeue *queue*)
  (format t "Dequeued: ~a~%" item)
  (format t "Remaining: ~a~%" new-queue)
  (setf *queue* new-queue))

(format t "~%=== STACKS (using lists) ===~%")

;;; Stack using push/pop
(defvar *stack* nil)

(push 'first *stack*)
(push 'second *stack*)
(push 'third *stack*)

(format t "Stack: ~a~%" *stack*)
(format t "Pop: ~a~%" (pop *stack*))
(format t "Remaining: ~a~%" *stack*)
