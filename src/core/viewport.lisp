(in-package #:pyx)

;;; spec

(defclass viewport-spec ()
  ((%name :reader name
          :initarg :name)
   (%x :accessor x)
   (%y :accessor y)
   (%width :accessor width)
   (%height :accessor height)))

(u:define-printer (viewport-spec stream :identity t)
  (format stream "~s" (name viewport-spec)))

(defun update-viewport-spec (name x y width height)
  (let ((spec (u:href =viewports= name)))
    (setf (x spec) (a:clamp (float x 1f0) 0f0 1f0)
          (y spec) (a:clamp (float y 1f0) 0f0 1f0)
          (width spec) (a:clamp (float width 1f0) 0f0 1f0)
          (height spec) (a:clamp (float height 1f0) 0f0 1f0))
    (enqueue :recompile (list :viewport))))

(defun make-viewport-spec (name x y width height)
  (let ((spec (make-instance 'viewport-spec :name name)))
    (setf (u:href =viewports= name) spec)
    (update-viewport-spec name x y width height)
    spec))

(defmacro define-viewport (name options &body body)
  (declare (ignore options))
  (destructuring-bind (&key (x 0) (y 0) (width 1) (height 1)) (car body)
    `(if (u:href =viewports= ',name)
         (update-viewport-spec ',name ,x ,y ,width ,height)
         (make-viewport-spec ',name ,x ,y ,width ,height))))

(define-viewport default ()
  (:x 0 :y 0 :width 1 :height 1))

;;; implementation

(defclass viewport-manager ()
  ((%table :reader table
           :initform (u:dict #'eq))
   (%active :accessor active
            :initform nil)
   (%default :accessor default)))

(defclass viewport ()
  ((%spec :reader spec
          :initarg :spec)
   (%camera :accessor camera
            :initform nil)
   (%draw-order :reader draw-order
                :initarg :draw-order)
   (%picking-ray :reader picking-ray
                 :initarg :picking-ray)
   (%x :accessor x
       :initform 0)
   (%y :accessor y
       :initform 0)
   (%width :accessor width
           :initform 0)
   (%height :accessor height
            :initform 0)))

(u:define-printer (viewport stream :identity t)
  (format stream "~s" (name (spec viewport))))

(defun make-viewport (name order ray)
  (let* ((spec (u:href =viewports= name))
         (viewport (make-instance 'viewport
                                  :spec spec
                                  :draw-order order
                                  :picking-ray ray)))
    (configure-viewport viewport)
    viewport))

(defun get-viewport-manager ()
  (viewports (current-scene)))

(defun get-viewport-by-coordinates (x y)
  (let ((manager (get-viewport-manager)))
    (u:do-hash-values (v (table manager))
      (when (and (<= (x v) x (+ (x v) (width v)))
                 (<= (y v) y (+ (y v) (height v))))
        (return-from get-viewport-by-coordinates v)))
    (default manager)))

(defun configure-viewport (viewport)
  (let ((spec (spec viewport)))
    (setf (x viewport) (a:lerp (x spec) 0 =window-width=)
          (y viewport) (a:lerp (y spec) 0 =window-height=)
          (width viewport) (a:lerp (width spec) 0 =window-width=)
          (height viewport) (a:lerp (height spec) 0 =window-height=)))
  (gl:viewport (x viewport)
               (y viewport)
               (width viewport)
               (height viewport)))

(defun get-entity-viewports (entity)
  (let ((scene-viewports (get-viewport-manager))
        (viewports nil))
    (dolist (id (comp::id/views entity))
      (let ((viewport (u:href (table scene-viewports) id)))
        (pushnew viewport viewports)))
    (or viewports (list (default scene-viewports)))))

(on-recompile :viewport data ()
  (recompile :scene (get-scene-name)))

(defun get-viewport-dimensions ()
  (let* ((manager (get-viewport-manager))
         (viewport (or (active manager)
                       (default manager))))
    (v2:vec (width viewport) (height viewport))))
