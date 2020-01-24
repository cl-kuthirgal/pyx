(in-package #:pyx)

;;; textures

(define-texture debug ()
  (:source "debug.png"))

;;; materials

(define-material full-quad ()
  (:shader pyx.shader:full-quad
   :uniforms (:sampler 'debug)))

(define-material quad ()
  (:shader pyx.shader:quad
   :uniforms (:sampler 'debug)))

(define-material mesh ()
  (:shader pyx.shader:mesh
   :uniforms (:sampler 'debug)))

(define-material collider ()
  (:shader pyx.shader:collider
   :uniforms (:hit-color (v4:vec 0 1 0 1)
              :miss-color (v4:vec 1 0 0 1))
   :features (:enable (:line-smooth)
              :polygon-mode :line
              :line-width 1.0)))

;;; collider plans

(define-collider-plan default ())

;;; render passes

(define-render-pass default ()
  (:clear-color (v4:vec 0 0 0 1)
   :clear-buffers (:color :depth)))

;;; views

(define-view default ()
  (:x 0 :y 0 :width 1 :height 1))
