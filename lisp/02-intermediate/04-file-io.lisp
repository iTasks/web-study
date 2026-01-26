;;;; 04-file-io.lisp
;;;; File input/output operations in Common Lisp
;;;;
;;;; This file demonstrates reading from and writing to files.

(format t "=== FILE WRITING ===~%")

;;; Write to a file
(defun write-sample-file ()
  "Create a sample text file"
  (with-open-file (stream "/tmp/lisp-sample.txt"
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Hello, Lisp!~%")
    (format stream "This is line 2.~%")
    (format stream "Numbers: ~{~a ~}~%" '(1 2 3 4 5))
    (format stream "End of file.~%"))
  (format t "File written to /tmp/lisp-sample.txt~%"))

(write-sample-file)

;;; Read entire file as string
(format t "~%=== READING FILE (String) ===~%")

(defun read-file-as-string (filename)
  "Read entire file contents as a string"
  (with-open-file (stream filename :direction :input)
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

(format t "File contents:~%~a~%" (read-file-as-string "/tmp/lisp-sample.txt"))

;;; Read file line by line
(format t "=== READING FILE (Line by Line) ===~%")

(defun read-file-lines (filename)
  "Read file and return list of lines"
  (with-open-file (stream filename :direction :input)
    (loop for line = (read-line stream nil)
          while line
          collect line)))

(format t "Lines in file:~%")
(dolist (line (read-file-lines "/tmp/lisp-sample.txt"))
  (format t "  ~a~%" line))

;;; Process file line by line with callback
(format t "~%=== PROCESSING LINES ===~%")

(defun process-file (filename func)
  "Apply function to each line of file"
  (with-open-file (stream filename :direction :input)
    (loop for line = (read-line stream nil)
          for line-num from 1
          while line
          do (funcall func line-num line))))

(format t "Numbered lines:~%")
(process-file "/tmp/lisp-sample.txt"
              (lambda (num line)
                (format t "Line ~a: ~a~%" num line)))

;;; Write data structures
(format t "~%=== WRITING DATA STRUCTURES ===~%")

(defun write-data-file ()
  "Write Lisp data structures to file"
  (with-open-file (stream "/tmp/lisp-data.lisp"
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (print '(defvar *my-list* (1 2 3 4 5)) stream)
    (print '(defvar *my-name* "Alice") stream)
    (print '(defun my-func (x) (* x x)) stream))
  (format t "Data file written to /tmp/lisp-data.lisp~%"))

(write-data-file)

;;; Read Lisp expressions from file
(format t "~%=== READING LISP EXPRESSIONS ===~%")

(defun read-expressions (filename)
  "Read Lisp expressions from file"
  (with-open-file (stream filename :direction :input)
    (loop for expr = (read stream nil)
          while expr
          collect expr)))

(format t "Expressions from file:~%")
(dolist (expr (read-expressions "/tmp/lisp-data.lisp"))
  (format t "  ~a~%" expr))

;;; Append to file
(format t "~%=== APPENDING TO FILE ===~%")

(defun append-to-file (filename text)
  "Append text to file"
  (with-open-file (stream filename
                          :direction :output
                          :if-exists :append
                          :if-does-not-exist :create)
    (format stream "~a~%" text)))

(append-to-file "/tmp/lisp-sample.txt" "Appended line 1")
(append-to-file "/tmp/lisp-sample.txt" "Appended line 2")
(format t "Appended to file~%")

;;; Check file existence
(format t "~%=== FILE EXISTENCE ===~%")

(defun file-exists-p (filename)
  "Check if file exists"
  (probe-file filename))

(format t "Does /tmp/lisp-sample.txt exist? ~a~%" 
        (if (file-exists-p "/tmp/lisp-sample.txt") "Yes" "No"))
(format t "Does /tmp/nonexistent.txt exist? ~a~%" 
        (if (file-exists-p "/tmp/nonexistent.txt") "Yes" "No"))

;;; Copy file
(format t "~%=== COPYING FILE ===~%")

(defun copy-file (source destination)
  "Copy file from source to destination"
  (with-open-file (in source :direction :input :element-type '(unsigned-byte 8))
    (with-open-file (out destination 
                         :direction :output 
                         :if-exists :supersede
                         :if-does-not-exist :create
                         :element-type '(unsigned-byte 8))
      (loop for byte = (read-byte in nil)
            while byte
            do (write-byte byte out)))))

(copy-file "/tmp/lisp-sample.txt" "/tmp/lisp-copy.txt")
(format t "File copied to /tmp/lisp-copy.txt~%")
