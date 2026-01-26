;;;; symbolic-ai.lisp
;;;; Demonstrates symbolic AI and knowledge representation in Lisp
;;;; Lisp was the primary language for AI research in the 1960s-1980s

;;; ============================================================================
;;; Knowledge Representation with Rules
;;; ============================================================================

;;; Define facts as simple lists
(defparameter *facts* '())

(defun add-fact (fact)
  "Add a fact to the knowledge base."
  (pushnew fact *facts* :test #'equal))

(defun clear-facts ()
  "Clear all facts from the knowledge base."
  (setf *facts* '()))

;;; ============================================================================
;;; Simple Expert System
;;; ============================================================================

(defparameter *rules* '())

(defstruct rule
  "A production rule with conditions and actions."
  name
  conditions
  actions)

(defun add-rule (name conditions actions)
  "Add a rule to the knowledge base."
  (push (make-rule :name name
                   :conditions conditions
                   :actions actions)
        *rules*))

(defun check-conditions (conditions facts)
  "Check if all conditions are satisfied by facts."
  (every (lambda (condition)
           (member condition facts :test #'equal))
         conditions))

(defun apply-rules (facts)
  "Apply all matching rules to facts."
  (dolist (rule *rules*)
    (when (check-conditions (rule-conditions rule) facts)
      (format t "Rule ~a fired!~%" (rule-name rule))
      (dolist (action (rule-actions rule))
        (format t "  Action: ~a~%" action)
        (add-fact action)))))

;;; ============================================================================
;;; Simple Animal Classification Expert System
;;; ============================================================================

(defun setup-animal-rules ()
  "Setup rules for animal classification."
  (setf *rules* '())
  
  (add-rule 'mammal-rule
            '((has-fur) (gives-milk))
            '((is-mammal)))
  
  (add-rule 'bird-rule
            '((has-feathers) (lays-eggs))
            '((is-bird)))
  
  (add-rule 'dog-rule
            '((is-mammal) (barks))
            '((is-dog)))
  
  (add-rule 'cat-rule
            '((is-mammal) (meows))
            '((is-cat)))
  
  (add-rule 'eagle-rule
            '((is-bird) (has-talons) (flies))
            '((is-eagle))))

(defun classify-animal ()
  "Demonstrate animal classification."
  (format t "=== Animal Classification Expert System ===~%~%")
  
  ;; Example 1: Dog
  (clear-facts)
  (format t "Example 1: Animal with fur, gives milk, barks~%")
  (setf *facts* '((has-fur) (gives-milk) (barks)))
  (apply-rules *facts*)
  (format t "Conclusion: ~a~%~%" *facts*)
  
  ;; Example 2: Eagle
  (clear-facts)
  (format t "Example 2: Animal with feathers, lays eggs, has talons, flies~%")
  (setf *facts* '((has-feathers) (lays-eggs) (has-talons) (flies)))
  (apply-rules *facts*)
  (format t "Conclusion: ~a~%~%" *facts*))

;;; ============================================================================
;;; Pattern Matching
;;; ============================================================================

(defun match-pattern (pattern data &optional bindings)
  "Simple pattern matching. Variables start with ?."
  (cond
    ;; Both are empty - success
    ((and (null pattern) (null data)) bindings)
    ;; One is empty - failure
    ((or (null pattern) (null data)) nil)
    ;; Variable binding
    ((and (symbolp (car pattern))
          (> (length (symbol-name (car pattern))) 0)
          (char= (char (symbol-name (car pattern)) 0) #\?))
     (let ((var (car pattern))
           (value (car data)))
       (let ((binding (assoc var bindings)))
         (if binding
             (if (equal (cdr binding) value)
                 (match-pattern (cdr pattern) (cdr data) bindings)
                 nil)
             (match-pattern (cdr pattern) (cdr data)
                           (cons (cons var value) bindings))))))
    ;; Equal elements
    ((equal (car pattern) (car data))
     (match-pattern (cdr pattern) (cdr data) bindings))
    ;; No match
    (t nil)))

(defun demo-pattern-matching ()
  "Demonstrate pattern matching."
  (format t "~%=== Pattern Matching ===~%~%")
  
  (let ((pattern '(likes ?person pizza))
        (data '(likes john pizza)))
    (format t "Pattern: ~a~%" pattern)
    (format t "Data: ~a~%" data)
    (format t "Match: ~a~%~%" (match-pattern pattern data)))
  
  (let ((pattern '(?person is-a ?type))
        (data '(socrates is-a human)))
    (format t "Pattern: ~a~%" pattern)
    (format t "Data: ~a~%" data)
    (format t "Match: ~a~%~%" (match-pattern pattern data))))

;;; ============================================================================
;;; Simple Natural Language Processing
;;; ============================================================================

(defparameter *vocabulary*
  '((hello . greeting)
    (hi . greeting)
    (bye . farewell)
    (goodbye . farewell)
    (thanks . gratitude)
    (thank . gratitude)
    (you . pronoun)
    (help . request)
    (please . politeness)))

(defun tokenize (sentence)
  "Simple tokenization by splitting on spaces."
  (let ((words (split-string sentence)))
    (mapcar (lambda (word)
              (intern (string-upcase word)))
            words)))

(defun split-string (string)
  "Split string by spaces."
  (let ((words '())
        (current-word ""))
    (loop for char across string
          do (if (char= char #\Space)
                 (when (> (length current-word) 0)
                   (push current-word words)
                   (setf current-word ""))
                 (setf current-word (concatenate 'string current-word (string char)))))
    (when (> (length current-word) 0)
      (push current-word words))
    (nreverse words)))

(defun analyze-sentence (sentence)
  "Analyze a sentence and identify word types."
  (let ((tokens (tokenize sentence)))
    (format t "Sentence: ~a~%" sentence)
    (format t "Tokens: ~a~%" tokens)
    (format t "Analysis:~%")
    (dolist (token tokens)
      (let ((type (cdr (assoc token *vocabulary*))))
        (format t "  ~a -> ~a~%"
                token
                (if type type 'unknown))))))

(defun demo-nlp ()
  "Demonstrate simple NLP."
  (format t "~%=== Natural Language Processing ===~%~%")
  (analyze-sentence "hello please help")
  (format t "~%")
  (analyze-sentence "thank you goodbye"))

;;; ============================================================================
;;; Search Algorithms
;;; ============================================================================

(defun depth-first-search (start goal successors-fn)
  "Depth-first search from start to goal."
  (labels ((dfs (node path)
             (cond
               ((equal node goal)
                (reverse (cons node path)))
               ((member node path :test #'equal)
                nil)
               (t
                (some (lambda (successor)
                        (dfs successor (cons node path)))
                      (funcall successors-fn node))))))
    (dfs start '())))

(defun breadth-first-search (start goal successors-fn)
  "Breadth-first search from start to goal."
  (let ((queue (list (list start))))
    (loop while queue
          for path = (pop queue)
          for node = (car path)
          when (equal node goal)
            do (return (reverse path))
          do (dolist (successor (funcall successors-fn node))
               (unless (member successor path :test #'equal)
                 (setf queue (append queue (list (cons successor path)))))))))

(defun demo-search ()
  "Demonstrate search algorithms."
  (format t "~%=== Search Algorithms ===~%~%")
  
  ;; Simple graph: A-B-C-D
  ;;               A-E-D
  (let ((graph '((A . (B E))
                 (B . (C))
                 (C . (D))
                 (E . (D))
                 (D . ()))))
    (flet ((successors (node)
             (cdr (assoc node graph))))
      
      (format t "Graph: ~a~%~%" graph)
      (format t "DFS from A to D: ~a~%"
              (depth-first-search 'A 'D #'successors))
      (format t "BFS from A to D: ~a~%"
              (breadth-first-search 'A 'D #'successors)))))

;;; ============================================================================
;;; Main Demo
;;; ============================================================================

(defun demo ()
  "Run all symbolic AI demonstrations."
  (setup-animal-rules)
  (classify-animal)
  (demo-pattern-matching)
  (demo-nlp)
  (demo-search))

;;; Run demo
(demo)
