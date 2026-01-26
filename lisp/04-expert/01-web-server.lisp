;;;; 01-web-server.lisp
;;;; Simple HTTP web server implementation
;;;;
;;;; This demonstrates building a real-world web server in Common Lisp.

(format t "=== SIMPLE HTTP WEB SERVER ===~%~%")

(format t "This file demonstrates web server concepts.~%")
(format t "For production use, consider libraries like:~%")
(format t "  - Hunchentoot~%")
(format t "  - Clack~%")
(format t "  - Woo~%~%")

;;; Basic TCP server utilities
(defpackage :web-server
  (:use :common-lisp)
  (:export :start-server :stop-server :define-route))

(in-package :web-server)

;;; Route storage
(defvar *routes* (make-hash-table :test 'equal)
  "Hash table storing routes")

;;; HTTP response builder
(defun make-http-response (status content-type body)
  "Build HTTP response string"
  (format nil "HTTP/1.1 ~a~%Content-Type: ~a~%Content-Length: ~a~%Connection: close~%~%~a"
          status
          content-type
          (length body)
          body))

;;; Parse HTTP request line
(defun parse-request-line (line)
  "Parse HTTP request line into method, path, version"
  ;; Simple string splitting without external dependencies
  (let* ((space-pos-1 (position #\Space line))
         (space-pos-2 (when space-pos-1 
                        (position #\Space line :start (1+ space-pos-1)))))
    (if (and space-pos-1 space-pos-2)
        (values (subseq line 0 space-pos-1)
                (subseq line (1+ space-pos-1) space-pos-2)
                (subseq line (1+ space-pos-2)))
        (values nil nil nil))))

;;; HTML page generator
(defun html-page (title body)
  "Generate complete HTML page"
  (format nil "<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <title>~a</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #333; }
        .container { max-width: 800px; margin: 0 auto; }
    </style>
</head>
<body>
    <div class='container'>
        <h1>~a</h1>
        ~a
    </div>
</body>
</html>" title title body))

;;; Route definition macro
(defmacro define-route (path &body handler-body)
  "Define a route handler"
  `(setf (gethash ,path *routes*)
         (lambda () ,@handler-body)))

;;; Example routes
(define-route "/"
  (html-page "Home" 
             "<p>Welcome to the Lisp Web Server!</p>
              <ul>
                <li><a href='/about'>About</a></li>
                <li><a href='/time'>Current Time</a></li>
                <li><a href='/fibonacci/10'>Fibonacci</a></li>
              </ul>"))

(define-route "/about"
  (html-page "About"
             "<p>This is a simple web server written in Common Lisp.</p>
              <p>It demonstrates:</p>
              <ul>
                <li>HTTP request handling</li>
                <li>Routing</li>
                <li>Dynamic content generation</li>
              </ul>
              <p><a href='/'>Home</a></p>"))

(define-route "/time"
  (html-page "Current Time"
             (format nil "<p>Server time: ~a</p>
                         <p><a href='/'>Home</a></p>"
                     (multiple-value-bind (sec min hr day mon yr)
                         (get-decoded-time)
                       (format nil "~4,'0d-~2,'0d-~2,'0d ~2,'0d:~2,'0d:~2,'0d"
                               yr mon day hr min sec)))))

;;; Handle request
(defun handle-request (request-line)
  "Handle HTTP request and return response"
  (multiple-value-bind (method path version)
      (parse-request-line request-line)
    (declare (ignore method version))
    
    (let ((handler (gethash path *routes*)))
      (if handler
          (make-http-response "200 OK" "text/html" (funcall handler))
          (make-http-response "404 Not Found" "text/html"
                            (html-page "404 Not Found"
                                     (format nil "<p>Page '~a' not found.</p>
                                                 <p><a href='/'>Home</a></p>"
                                             path)))))))

;;; Note: Full server implementation would require:
;;; 1. Socket programming (implementation-specific)
;;; 2. Thread/process management
;;; 3. Request parsing (headers, body)
;;; 4. Response handling
;;; 5. Error handling

(in-package :common-lisp-user)

(format t "Web server concepts demonstrated:~%")
(format t "  ✓ Route definition and handling~%")
(format t "  ✓ HTTP response generation~%")
(format t "  ✓ Dynamic HTML generation~%")
(format t "  ✓ Request parsing~%")
(format t "~%For real web applications, use established libraries!~%")

;;; Example of generating a response
(format t "~%Example HTTP Response:~%")
(format t "~a~%" 
        (web-server::make-http-response 
         "200 OK" 
         "text/html"
         (web-server::html-page "Test" "<p>Hello, World!</p>")))
