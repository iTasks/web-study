;;;; neural-network.lisp
;;;; Simple Neural Network implementation in Common Lisp
;;;; Demonstrates feedforward networks and backpropagation

;;; ============================================================================
;;; Math Utilities
;;; ============================================================================

(defun sigmoid (x)
  "Sigmoid activation function: 1 / (1 + e^-x)."
  (/ 1 (+ 1 (exp (- x)))))

(defun sigmoid-derivative (x)
  "Derivative of sigmoid function."
  (let ((s (sigmoid x)))
    (* s (- 1 s))))

(defun relu (x)
  "ReLU activation function: max(0, x)."
  (max 0 x))

(defun relu-derivative (x)
  "Derivative of ReLU function."
  (if (> x 0) 1 0))

(defun tanh-activation (x)
  "Hyperbolic tangent activation function."
  (tanh x))

(defun tanh-derivative (x)
  "Derivative of tanh function."
  (let ((t-val (tanh x)))
    (- 1 (* t-val t-val))))

(defun random-weight ()
  "Generate random weight between -1 and 1."
  (- (random 2.0) 1.0))

(defun dot-product (v1 v2)
  "Calculate dot product of two vectors."
  (reduce #'+ (mapcar #'* v1 v2)))

;;; ============================================================================
;;; Matrix Operations
;;; ============================================================================

(defun make-matrix (rows cols &optional (init-fn #'random-weight))
  "Create a matrix with random or specified values."
  (loop repeat rows
        collect (loop repeat cols
                     collect (funcall init-fn))))

(defun matrix-multiply-vector (matrix vector)
  "Multiply matrix by vector."
  (mapcar (lambda (row)
            (dot-product row vector))
          matrix))

(defun vector-add (v1 v2)
  "Add two vectors element-wise."
  (mapcar #'+ v1 v2))

(defun vector-subtract (v1 v2)
  "Subtract v2 from v1 element-wise."
  (mapcar #'- v1 v2))

(defun vector-multiply (v1 v2)
  "Multiply two vectors element-wise."
  (mapcar #'* v1 v2))

(defun scalar-multiply (scalar vector)
  "Multiply vector by scalar."
  (mapcar (lambda (x) (* scalar x)) vector))

;;; ============================================================================
;;; Neural Network Structure
;;; ============================================================================

(defstruct layer
  "A layer in a neural network."
  weights        ; Weight matrix
  biases         ; Bias vector
  activation     ; Activation function
  activation-derivative) ; Derivative of activation

(defstruct network
  "A neural network."
  layers         ; List of layers
  learning-rate) ; Learning rate for training

(defun create-network (layer-sizes &key (learning-rate 0.1) (activation #'sigmoid))
  "Create a neural network with specified layer sizes."
  (let ((layers '()))
    (loop for i from 0 below (1- (length layer-sizes))
          for input-size = (nth i layer-sizes)
          for output-size = (nth (1+ i) layer-sizes)
          do (push (make-layer
                    :weights (make-matrix output-size input-size)
                    :biases (make-list output-size :initial-element 0.0)
                    :activation activation
                    :activation-derivative (if (eq activation #'sigmoid)
                                              #'sigmoid-derivative
                                              #'tanh-derivative))
                   layers))
    (make-network :layers (nreverse layers)
                  :learning-rate learning-rate)))

;;; ============================================================================
;;; Forward Propagation
;;; ============================================================================

(defun forward-layer (layer input)
  "Forward propagate through a single layer."
  (let* ((weighted-sum (matrix-multiply-vector (layer-weights layer) input))
         (with-bias (vector-add weighted-sum (layer-biases layer)))
         (activated (mapcar (layer-activation layer) with-bias)))
    (values activated with-bias)))

(defun forward-propagate (network input)
  "Forward propagate through the entire network."
  (let ((activations (list input))
        (z-values '()))
    (dolist (layer (network-layers network))
      (multiple-value-bind (activation z)
          (forward-layer layer (car activations))
        (push activation activations)
        (push z z-values)))
    (values (nreverse activations) (nreverse z-values))))

(defun predict (network input)
  "Make a prediction using the network."
  (multiple-value-bind (activations z-values)
      (forward-propagate network input)
    (declare (ignore z-values))
    (car (last activations))))

;;; ============================================================================
;;; Backpropagation
;;; ============================================================================

(defun compute-output-delta (output target z-values activation-derivative)
  "Compute delta for output layer."
  (let ((error (vector-subtract output target))
        (derivative (mapcar activation-derivative z-values)))
    (vector-multiply error derivative)))

(defun compute-hidden-delta (next-delta next-weights z-values activation-derivative)
  "Compute delta for hidden layer."
  (let ((error (matrix-multiply-vector
                (transpose-matrix next-weights)
                next-delta))
        (derivative (mapcar activation-derivative z-values)))
    (vector-multiply error derivative)))

(defun transpose-matrix (matrix)
  "Transpose a matrix."
  (apply #'mapcar #'list matrix))

(defun update-weights (layer delta previous-activation learning-rate)
  "Update weights and biases using gradient descent."
  (let ((new-weights
         (mapcar (lambda (weight-row delta-val)
                   (mapcar (lambda (weight prev-act)
                             (- weight (* learning-rate delta-val prev-act)))
                           weight-row
                           previous-activation))
                 (layer-weights layer)
                 delta))
        (new-biases
         (mapcar (lambda (bias delta-val)
                   (- bias (* learning-rate delta-val)))
                 (layer-biases layer)
                 delta)))
    (setf (layer-weights layer) new-weights)
    (setf (layer-biases layer) new-biases)))

(defun train-step (network input target)
  "Perform one training step (forward + backward pass)."
  (multiple-value-bind (activations z-values)
      (forward-propagate network input)
    
    ;; Compute deltas
    (let ((deltas '())
          (layers (network-layers network)))
      
      ;; Output layer delta
      (let ((output-delta
             (compute-output-delta
              (car (last activations))
              target
              (car (last z-values))
              (layer-activation-derivative (car (last layers))))))
        (push output-delta deltas))
      
      ;; Hidden layer deltas (backward)
      (loop for i from (- (length layers) 2) downto 0
            for layer = (nth i layers)
            for next-layer = (nth (1+ i) layers)
            do (push (compute-hidden-delta
                      (car deltas)
                      (layer-weights next-layer)
                      (nth (1+ i) z-values)
                      (layer-activation-derivative layer))
                     deltas))
      
      ;; Update weights
      (loop for layer in layers
            for delta in deltas
            for activation in activations
            do (update-weights layer delta activation
                              (network-learning-rate network))))))

(defun train (network training-data epochs)
  "Train the network on training data for specified epochs."
  (dotimes (epoch epochs)
    (let ((total-error 0))
      (dolist (example training-data)
        (let* ((input (car example))
               (target (cadr example))
               (output (predict network input))
               (error (reduce #'+ (mapcar (lambda (out-val target-val)
                                           (* (- out-val target-val) 
                                              (- out-val target-val)))
                                         output target))))
          (train-step network input target)
          (incf total-error error)))
      
      (when (zerop (mod epoch 100))
        (format t "Epoch ~a, Error: ~,6f~%" epoch total-error)))))

;;; ============================================================================
;;; Examples and Demonstrations
;;; ============================================================================

(defun demo-xor ()
  "Demonstrate XOR learning - a classic non-linearly separable problem."
  (format t "~%=== XOR Problem ===~%~%")
  
  ;; Create network: 2 inputs, 4 hidden neurons, 1 output
  (let ((net (create-network '(2 4 1) :learning-rate 0.5 :activation #'sigmoid))
        (training-data '(((0 0) (0))
                        ((0 1) (1))
                        ((1 0) (1))
                        ((1 1) (0)))))
    
    (format t "Training XOR network...~%")
    (train net training-data 1000)
    
    (format t "~%Testing XOR network:~%")
    (dolist (example training-data)
      (let* ((input (car example))
             (expected (cadr example))
             (output (predict net input)))
        (format t "Input: ~a, Expected: ~a, Output: ~,3f~%"
                input expected (car output))))))

(defun demo-simple-classification ()
  "Demonstrate simple binary classification."
  (format t "~%~%=== Simple Classification ===~%~%")
  
  ;; Create network: 2 inputs, 3 hidden neurons, 1 output
  (let ((net (create-network '(2 3 1) :learning-rate 0.3 :activation #'sigmoid)))
    
    ;; Training data: classify points above/below y=x line
    (let ((training-data '(((0.1 0.9) (1))  ; Above line
                          ((0.2 0.8) (1))
                          ((0.3 0.7) (1))
                          ((0.7 0.3) (0))  ; Below line
                          ((0.8 0.2) (0))
                          ((0.9 0.1) (0)))))
      
      (format t "Training classification network...~%")
      (train net training-data 500)
      
      (format t "~%Testing classification:~%")
      (dolist (test-point '((0.15 0.85) (0.85 0.15) (0.5 0.5)))
        (let ((output (predict net test-point)))
          (format t "Point ~a: ~,3f (~a line)~%"
                  test-point
                  (car output)
                  (if (> (car output) 0.5) "above" "below")))))))

(defun demo-activations ()
  "Demonstrate different activation functions."
  (format t "~%~%=== Activation Functions ===~%~%")
  
  (let ((test-values '(-2 -1 0 1 2)))
    (format t "Sigmoid:~%")
    (dolist (x test-values)
      (format t "  sigmoid(~a) = ~,4f~%" x (sigmoid x)))
    
    (format t "~%ReLU:~%")
    (dolist (x test-values)
      (format t "  relu(~a) = ~,4f~%" x (relu x)))
    
    (format t "~%Tanh:~%")
    (dolist (x test-values)
      (format t "  tanh(~a) = ~,4f~%" x (tanh-activation x)))))

;;; ============================================================================
;;; Main Demo
;;; ============================================================================

(defun demo ()
  "Run all neural network demonstrations."
  (format t "=== Neural Network Implementation in Lisp ===~%")
  (demo-activations)
  (demo-xor)
  (demo-simple-classification)
  
  (format t "~%~%=== Summary ===~%")
  (format t "This demonstrates a simple feedforward neural network with:~%")
  (format t "- Multiple activation functions (sigmoid, ReLU, tanh)~%")
  (format t "- Forward propagation~%")
  (format t "- Backpropagation for training~%")
  (format t "- Gradient descent optimization~%")
  (format t "~%Lisp's symbolic processing and list manipulation make it~%")
  (format t "excellent for implementing AI algorithms!~%"))

;;; Run demo
(demo)
