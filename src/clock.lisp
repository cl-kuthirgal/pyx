(in-package #:pyx)

(defstruct (clock (:constructor %make-clock)
                  (:predicate nil)
                  (:copier nil))
  (accumulator 0d0)
  (current-time 0d0)
  (debug-count 0)
  (debug-interval 10)
  (debug-time 0d0)
  (delta-buffer 0d0)
  (delta-time (/ 60f0))
  (frame-count 0)
  (frame-time 0d0)
  (init-time 0)
  (interpolation-factor 0f0)
  (pause-time 0d0)
  (period-elapsed 0d0)
  (period-interval 0.25d0)
  (previous-time 0d0))

(defun make-clock ()
  (let ((clock (%make-clock)))
    (setf (clock-init-time clock) (sb-ext:get-time-of-day)
          (clock-current-time clock) 0d0
          (clock-debug-time clock) 0d0
          (slot-value *state* '%clock) clock)
    ;; NOTE: We have to tick the clock and resolve an initial model matrix for
    ;; all entities as soon as we initialize the clock times in order to work
    ;; around a bug resulting in identity transforms on frame 1.
    (clock-tick)
    (map-nodes #'resolve-model)
    (u:noop)))

(defun get-time (clock)
  (u:mvlet ((s us (sb-ext:get-time-of-day)))
    (+ (- s (clock-init-time clock))
       (/ us 1d6))))

(defun smooth-delta-time (clock refresh-rate)
  (symbol-macrolet ((frame-time (clock-frame-time clock))
                    (buffer (clock-delta-buffer clock)))
    (incf frame-time buffer)
    (let ((frame-count (max 1 (truncate (1+ (* frame-time refresh-rate)))))
          (previous frame-time))
      (setf frame-time (/ frame-count refresh-rate)
            buffer (- previous frame-time))
      (u:noop))))

(defun calculate-frame-rate (clock)
  (symbol-macrolet ((debug-time (clock-debug-time clock))
                    (debug-interval (clock-debug-interval clock))
                    (debug-count (clock-debug-count clock)))
    (let* ((current (clock-current-time clock))
           (elapsed (- current debug-time))
           (fps (/ debug-count debug-interval)))
      (when (and (>= elapsed debug-interval)
                 (plusp fps))
        (log:info :pyx.clock "Frame rate: ~,2f fps / ~,3f ms/f"
                  fps (/ 1000 fps))
        (setf debug-count 0
              debug-time current))
      (incf debug-count)
      (u:noop))))

(defun clock-update ()
  (let ((clock (clock *state*)))
    (symbol-macrolet ((accumulator (clock-accumulator clock))
                      (delta (clock-delta-time clock)))
      (incf accumulator (clock-frame-time clock))
      (u:while (>= accumulator delta)
        (map-nodes #'on-update)
        (decf accumulator delta))
      (setf (clock-interpolation-factor clock)
            (float (/ accumulator delta) 1f0))
      (u:noop))))

(defun clock-update/periodic ()
  (let ((clock (clock *state*)))
    (symbol-macrolet ((current (clock-current-time clock))
                      (elapsed (clock-period-elapsed clock)))
      (when (>= (- current elapsed) (clock-period-interval clock))
        (run-periodic-tasks)
        (setf elapsed current))
      (u:noop))))

(defun clock-tick ()
  (let ((clock (clock *state*))
        (refresh-rate (refresh-rate (display *state*))))
    (symbol-macrolet ((previous (clock-previous-time clock))
                      (current (clock-current-time clock))
                      (pause (clock-pause-time clock)))
      (setf previous (+ current pause)
            current (- (get-time clock) pause)
            (clock-frame-time clock) (- current previous)
            pause 0d0)
      (when (cfg :vsync)
        (smooth-delta-time clock refresh-rate))
      (clock-update)
      (clock-update/periodic)
      (calculate-frame-rate clock)
      (u:noop))))
