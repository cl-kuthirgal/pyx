(in-package #:pyx)

(define-component camera
  (:view (m4:id)
   :projection (m4:id)
   :clip-near 0.0
   :clip-far 64.0
   :fov-y 45f0
   :zoom 1))

(defun set-camera-projection (entity)
  (with-slots (%camera/projection %camera/clip-near %camera/clip-far) entity
    (let* ((zoom (camera/zoom entity))
           (w (/ (cfg :window-width) zoom 2))
           (h (/ (cfg :window-height) zoom 2)))
      (m4:set-projection/orthographic!
       %camera/projection (- w) w (- h) h %camera/clip-near
       %camera/clip-far))))

(defun set-camera-view (entity)
  (let* ((model (xform/model entity))
         (eye (m4:get-translation model))
         (target (v3:+ eye (v3:negate (m4:rotation-axis-to-vec3 model :z))))
         (up (m4:rotation-axis-to-vec3 model :y)))
    (m4:set-view! (camera/view entity) eye target up)))

(defun zoom-camera (entity direction)
  (with-slots (%camera/zoom) entity
    (setf %camera/zoom (a:clamp (+ %camera/zoom (/ direction 2)) 1 10))
    (set-camera-projection entity)))

(defun make-camera ()
  (setf (slot-value *state* '%camera) (make-entity (camera))))

(defmethod on-component-added ((component (eql 'camera)) entity)
  (set-camera-projection entity)
  (set-camera-view entity))
