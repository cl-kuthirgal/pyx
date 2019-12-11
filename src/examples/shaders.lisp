(in-package #:pyx.examples.shader)

;;; graph

(defun graph/f ((uv :vec2)
                &uniforms
                (time :float))
  (let* ((dim (vec2 (1+ (sin time)) (+ 2 (sin time))))
         (uv (+ (* uv (- (.y dim) (.x dim)))
                (vec2 (.x dim) -0.5))))
    (umbra.graphing:graph
     (lambda ((x :float))
       (* (sin (* x x x)) (sin x)))
     (* 4 uv)
     (vec4 0 1 0 0.5)
     (vec4 1 1 1 0.02)
     10)))

(define-shader graph ()
  (:vertex (pyx.shader:quad/v mesh-attrs))
  (:fragment (graph/f :vec2)))

;;; noise

(defun noise/perlin-3d/f ((uv :vec2)
                          &uniforms
                          (time :float))
  (let ((noise (vec3 (umbra.noise:perlin (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/perlin-surflet-3d/f ((uv :vec2)
                                  &uniforms
                                  (time :float))
  (let ((noise (vec3 (umbra.noise:perlin-surflet (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/perlin-improved-3d/f ((uv :vec2)
                                   &uniforms
                                   (time :float))
  (let ((noise (vec3 (umbra.noise:perlin-improved (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/perlin-4d/f ((uv :vec2)
                          &uniforms
                          (time :float))
  (let ((noise (vec3 (umbra.noise:perlin (vec4 (* 10 uv) time (/ time 2))))))
    (vec4 noise 1)))

(defun noise/cellular-3d/f ((uv :vec2)
                            &uniforms
                            (time :float))
  (let ((noise (vec3 (umbra.noise:cellular (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/cellular-fast-3d/f ((uv :vec2)
                                 &uniforms
                                 (time :float))
  (let ((noise (vec3 (umbra.noise:cellular-fast (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/hermite-3d/f ((uv :vec2)
                           &uniforms
                           (time :float))
  (let ((noise (vec3 (umbra.noise:hermite (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/simplex-perlin-3d/f ((uv :vec2)
                                  &uniforms
                                  (time :float))
  (let ((noise (vec3 (umbra.noise:simplex-perlin (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/simplex-cellular-3d/f ((uv :vec2)
                                    &uniforms
                                    (time :float))
  (let ((noise (vec3 (umbra.noise:simplex-cellular (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/simplex-polkadot-3d/f ((uv :vec2)
                                    &uniforms
                                    (time :float))
  (let ((noise (vec3 (umbra.noise:simplex-polkadot
                      (vec3 (* 10 uv) time) 1.0 1.0))))
    (vec4 noise 1)))

(defun noise/value-3d/f ((uv :vec2)
                         &uniforms
                         (time :float))
  (let ((noise (vec3 (umbra.noise:value (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/value-4d/f ((uv :vec2)
                         &uniforms
                         (time :float))
  (let ((noise (vec3 (umbra.noise:value (vec4 (* 10 uv) time (/ time 2))))))
    (vec4 noise 1)))

(defun noise/hermite-3d/f ((uv :vec2)
                           &uniforms
                           (time :float))
  (let ((noise (vec3 (umbra.noise:hermite (vec3 (* 10 uv) time)))))
    (vec4 noise 1)))

(defun noise/value-hermite-3d/f ((uv :vec2)
                                 &uniforms
                                 (time :float))
  (let ((noise (vec3 (umbra.noise:value-hermite
                      (vec3 (* 10 uv) time) 0.5 0.5 1.0))))
    (vec4 noise 1)))

(defun noise/value-perlin-3d/f ((uv :vec2)
                                &uniforms
                                (time :float))
  (let ((noise (vec3 (umbra.noise:value-perlin (vec3 (* 10 uv) time) 0.5))))
    (vec4 noise 1)))

(defun noise/polkadot-3d/f ((uv :vec2)
                            &uniforms
                            (time :float))
  (let ((noise (vec3 (umbra.noise:polkadot (vec3 (* 10 uv) time) 0.0 1.0))))
    (vec4 noise 1)))

(defun noise/polkadot-box-3d/f ((uv :vec2)
                                &uniforms
                                (time :float))
  (let ((noise (vec3 (umbra.noise:polkadot-box (vec3 (* 10 uv) time) 0.0 1.0))))
    (vec4 noise 1)))

(defun noise/cubist-3d/f ((uv :vec2)
                          &uniforms
                          (time :float))
  (let ((noise (vec3 (umbra.noise:cubist (vec3 (* 10 uv) time) (vec2 0 1.0)))))
    (vec4 noise 1)))

(define-shader noise/perlin-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/perlin-3d/f :vec2)))

(define-shader noise/perlin-surflet-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/perlin-surflet-3d/f :vec2)))

(define-shader noise/perlin-improved-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/perlin-improved-3d/f :vec2)))

(define-shader noise/perlin-4d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/perlin-4d/f :vec2)))

(define-shader noise/cellular-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/cellular-3d/f :vec2)))

(define-shader noise/cellular-fast-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/cellular-fast-3d/f :vec2)))

(define-shader noise/hermite-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/hermite-3d/f :vec2)))

(define-shader noise/simplex-perlin-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/simplex-perlin-3d/f :vec2)))

(define-shader noise/simplex-cellular-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/simplex-cellular-3d/f :vec2)))

(define-shader noise/simplex-polkadot-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/simplex-polkadot-3d/f :vec2)))

(define-shader noise/value-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/value-3d/f :vec2)))

(define-shader noise/value-4d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/value-4d/f :vec2)))

(define-shader noise/value-hermite-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/value-hermite-3d/f :vec2)))

(define-shader noise/value-perlin-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/value-perlin-3d/f :vec2)))

(define-shader noise/polkadot-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/polkadot-3d/f :vec2)))

(define-shader noise/polkadot-box-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/polkadot-box-3d/f :vec2)))

(define-shader noise/cubist-3d ()
  (:vertex (pyx.shader:default/v mesh-attrs))
  (:fragment (noise/cubist-3d/f :vec2)))