(in-package #:pyx)

(defclass material-spec ()
  ((%name :reader name
          :initarg :name)
   (%master :accessor master
            :initarg :master
            :initform nil)
   (%slaves :accessor slaves
            :initform nil)
   (%shader :reader shader
            :initarg :shader)
   (%uniforms :reader uniforms
              :initform (make-nested-dict #'eq :self :resolved))
   (%blend-mode :reader blend-mode
                :initarg :blend-mode)
   (%depth-mode :reader depth-mode
                :initarg :depth-mode)
   (%features/enabled :reader features/enabled
                      :initarg :features/enabled)
   (%features/disabled :reader features/disabled
                       :initarg :features/disabled)
   (%output :reader output
            :initarg :output)))

(defun find-material-spec-master (spec)
  (let* ((master-name (master spec))
         (master-spec (meta :materials master-name)))
    (when (and master-name (not master-spec))
      (error "Material ~s inherits from the unknown master ~s."
             (name spec)
             master-name))
    master-spec))

(defun copy-material-spec-uniforms (spec)
  (let ((uniforms (u:dict #'eq)))
    (labels ((copy (value)
               (typecase value
                 (sequence (map-into (copy-seq value) #'copy value))
                 (t value))))
      (when spec
        (u:do-hash (k v (u:href (uniforms spec) :resolved))
          (setf (u:href uniforms k) (copy v))))
      uniforms)))

(defun update-material-spec-uniforms (spec uniforms)
  (with-slots (%uniforms) spec
    (let* ((master-spec (find-material-spec-master spec))
           (self (apply #'u:dict #'eq uniforms))
           (resolved (u:hash-merge (copy-material-spec-uniforms master-spec)
                                   self)))
      (clrhash (u:href %uniforms :self))
      (clrhash (u:href %uniforms :resolved))
      (u:do-hash (k v self)
        (setf (u:href %uniforms :self k) v))
      (u:do-hash (k v resolved)
        (setf (u:href %uniforms :resolved k) v)))))

(defun update-material-spec-relationships (spec)
  (a:when-let ((master (meta :materials (master spec))))
    (pushnew (name spec) (slaves master))))

(defun make-material-spec (name &rest args)
  (destructuring-bind (&key master shader uniforms blend-mode depth-mode
                         features output)
      args
    (destructuring-bind (&key enable disable) features
      (let* ((master-spec (meta :materials master))
             (shader (or shader (and master-spec (shader master-spec))))
             (blend-mode (or blend-mode +gl-blend-mode+))
             (depth-mode (or depth-mode +gl-depth-mode+))
             (features/enabled (set-difference
                                enable +gl-capabilities/enabled+))
             (features/disabled (set-difference
                                 disable +gl-capabilities/disabled+)))
        (symbol-macrolet ((spec (meta :materials name)))
          (if spec
              (apply #'update-material-spec spec
                     :shader shader
                     :blend-mode blend-mode
                     :depth-mode depth-mode
                     :features/enabled features/enabled
                     :features/disabled features/disabled
                     args)
              (progn
                (setf spec (make-instance 'material-spec
                                          :name name
                                          :master master
                                          :shader shader
                                          :blend-mode blend-mode
                                          :depth-mode depth-mode
                                          :features/enabled features/enabled
                                          :features/disabled features/disabled
                                          :output output))
                (update-material-spec-uniforms spec uniforms)
                (update-material-spec-relationships spec))))))))

(defun update-material-spec (spec &rest args)
  (destructuring-bind (&key master shader uniforms blend-mode depth-mode
                         features/enabled features/disabled output
                       &allow-other-keys)
      args
    (with-slots (%name %master %shader %blend-mode %depth-mode %features/enabled
                 %features/disabled %output)
        spec
      (setf %master master
            %shader shader
            %blend-mode blend-mode
            %depth-mode depth-mode
            %features/enabled features/enabled
            %features/disabled features/disabled
            %output output)
      (update-material-spec-uniforms spec uniforms)
      (update-material-spec-relationships spec)
      (enqueue :recompile (list :material %name))
      (dolist (slave-name (slaves spec))
        (let ((slave (meta :materials slave-name)))
          (update-material-spec
           slave
           :master %name
           :shader (or (shader slave) shader)
           :uniforms (u:hash->plist (u:href (uniforms slave) :self))
           :blend-mode (blend-mode slave)
           :depth-mode (depth-mode slave)
           :features/enabled (features/enabled slave)
           :features/disabled (features/disabled slave)
           :output (output slave)))))))

(defmacro define-material (name (&optional master) &body body)
  (destructuring-bind (&key shader uniforms blend-mode depth-mode features
                         output)
      (car body)
    `(progn
       (unless (meta :materials)
         (setf (meta :materials) (u:dict #'eq)))
       (make-material-spec ',name
                           :master ',master
                           :shader ',shader
                           :uniforms (list ,@uniforms)
                           :blend-mode ',blend-mode
                           :depth-mode ',depth-mode
                           :features ',features
                           :output ',output))))
