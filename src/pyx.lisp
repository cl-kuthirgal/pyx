(in-package #:pyx)

(defun initialize (scene-name args)
  (apply #'load-config args)
  (initialize-rng)
  (prepare-gamepads)
  (make-display)
  (make-input-data)
  (load-hardware-info)
  (make-thread-pool)
  (initialize-shaders)
  (switch-scene scene-name)
  (make-clock)
  (setup-repl)
  (start-loop))

(defun deinitialize ()
  (kill-display)
  (destroy-thread-pool)
  (shutdown-gamepads)
  (sdl2:quit))

(defun update ()
  (let ((alpha (get-alpha)))
    (comp::do-nodes (node)
      (comp::resolve-model node alpha)
      (on-update node))))

(defun physics-update ()
  (comp::map-nodes #'on-physics-update)
  (comp::do-nodes (node)
    (comp:transform-node node))
  (compute-collisions))

(defun periodic-update ()
  #-pyx.release (update-repl)
  (process-queue :recompile))

(defun start-loop ()
  (let* ((clock (clock))
         (display (display))
         (input-data (input-data))
         (refresh-rate (refresh-rate display)))
    (update)
    (u:while (running-p)
      (with-continuable "Pyx"
        (handle-events input-data)
        (tick-clock clock refresh-rate #'physics-update #'periodic-update)
        (update)
        (render display)))))

(defun start-engine (scene-name &rest args)
  (let ((*context* (make-instance 'context)))
    (unwind-protect (initialize scene-name args)
      (deinitialize))))

(defun stop-engine ()
  (setf (running-p) nil))
