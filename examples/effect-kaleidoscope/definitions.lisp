(in-package #:pyx.examples)

;;; materials

(pyx:define-material effect/kaleidoscope ()
  (:shader pyx.examples.shader:effect/kaleidoscope
   :uniforms (:time #'pyx:get-total-time
              :res #'pyx:get-window-resolution
              :zoom 0.85
              :speed 1
              :strength 0.7
              :colorize nil
              :outline nil
              :detail 0.8)))

;;; prefabs

(pyx:define-prefab effect/kaleidoscope (:template quad)
  :render/materials '(effect/kaleidoscope))

;;; scene

(pyx:define-scene effect/kaleidoscope ()
  (:prefabs (camera/orthographic effect/kaleidoscope)))
