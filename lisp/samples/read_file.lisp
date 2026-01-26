;;;; read_file.lisp
;;;; Demonstrates file I/O operations in Common Lisp

;;; Read and display file contents line by line
(defun read-file-lines (filename)
  "Read a file and print each line with line numbers."
  (with-open-file (stream filename :direction :input :if-does-not-exist nil)
    (if stream
        (loop for line = (read-line stream nil)
              for line-num from 1
              while line
              do (format t "~3d: ~a~%" line-num line))
        (format t "Error: File '~a' not found.~%" filename))))

;;; Count lines in a file
(defun count-file-lines (filename)
  "Count the number of lines in a file."
  (with-open-file (stream filename :direction :input :if-does-not-exist nil)
    (if stream
        (loop for line = (read-line stream nil)
              while line
              count line)
        0)))

;;; Read entire file into a string
(defun read-file-to-string (filename)
  "Read entire file contents into a string."
  (with-open-file (stream filename :direction :input :if-does-not-exist nil)
    (if stream
        (let ((contents (make-string (file-length stream))))
          (read-sequence contents stream)
          contents)
        "")))

;;; Write text to a file
(defun write-to-file (filename text)
  "Write text to a file, overwriting if it exists."
  (with-open-file (stream filename 
                          :direction :output 
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "~a" text))
  (format t "Successfully wrote to ~a~%" filename))

;;; Demonstration
(defun demo ()
  "Demonstrate file I/O operations."
  (let ((test-file "/tmp/lisp-test.txt"))
    ;; Write to file
    (with-open-file (stream test-file 
                            :direction :output 
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (format stream "Hello, Lisp!~%")
      (format stream "This is a test file.~%")
      (format stream "Line 3~%"))
    (format t "Successfully wrote to ~a~%" test-file)
    
    ;; Read and display
    (format t "~%File contents:~%")
    (read-file-lines test-file)
    
    ;; Count lines
    (format t "~%Total lines: ~d~%" (count-file-lines test-file))))

;;; Run demo if this file is executed as a script
(demo)
