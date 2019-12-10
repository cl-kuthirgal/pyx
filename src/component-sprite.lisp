(in-package #:pyx)

(define-component sprite ()
  ((%sprite/name :reader sprite/name
                 :initarg :sprite/name)
   (%sprite/texture :reader sprite/texture
                    :initarg :sprite/texture
                    :initform 'default)
   (%sprite/frames :reader sprite/frames
                   :initarg :sprite/frames
                   :initform 1)
   (%sprite/spritesheet :accessor sprite/spritesheet)
   (%sprite/index :accessor sprite/index)
   (%sprite/initial-index :accessor sprite/initial-index))
  (:sorting :after render))

;;; entity hooks

(define-hook :entity-create (entity sprite)
  (let ((spritesheet (make-spritesheet sprite/texture)))
    (setf sprite/spritesheet spritesheet
          sprite/index (u:href (sprites spritesheet) sprite/name)
          sprite/initial-index sprite/index)))

(define-hook :entity-render (entity sprite)
  (set-uniforms (render/current-material entity)
                :sprite.index sprite/index
                :sprite.sampler (texture sprite/spritesheet))
  (gl:bind-vertex-array (vao sprite/spritesheet))
  (gl:draw-arrays :points 0 1)
  (gl:bind-vertex-array 0))
