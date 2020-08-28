(in-package #:net.mfiano.lisp.pyx)

(defstruct (display
            (:constructor %make-display)
            (:predicate nil)
            (:copier nil))
  window
  context
  (resolution (v2:vec (cfg/player :window-width)
                      (cfg/player :window-height))
   :type v2:vec)
  (refresh-rate 60 :type fixnum))

(defun make-opengl-context (display)
  (sdl2:gl-set-attrs :context-major-version 4
                     :context-minor-version 3
                     :context-profile-mask 1
                     :multisamplebuffers (if (cfg :anti-alias) 1 0)
                     :multisamplesamples (if (cfg :anti-alias) 4 0))
  (let ((context (sdl2:gl-create-context (display-window display))))
    (setf (display-context display) context)
    (apply #'gl:enable +enabled-capabilities+)
    (apply #'gl:disable +disabled-capabilities+)
    (apply #'gl:blend-func +blend-mode+)
    (gl:depth-func +depth-mode+)))

(defun make-window ()
  (sdl2:create-window :title (cfg :title)
                      :w (truncate (cfg/player :window-width))
                      :h (truncate (cfg/player :window-height))
                      :flags '(:opengl)))

(defun make-display ()
  (sdl2:init :everything)
  (let* ((refresh-rate (nth-value 3 (sdl2:get-current-display-mode 0)))
         (resolution (v2:vec (cfg/player :window-width)
                             (cfg/player :window-height)))
         (display (%make-display :window (make-window)
                                 :refresh-rate refresh-rate
                                 :resolution resolution)))
    (make-opengl-context display)
    (sdl2:gl-set-swap-interval (if (cfg :vsync) 1 0))
    (if (cfg/player :allow-screensaver)
        (sdl2:enable-screensaver)
        (sdl2:disable-screensaver))
    (setf (display =context=) display)))

(defun kill-display ()
  (u:when-let ((display (display =context=)))
    (sdl2:gl-delete-context (display-context display))
    (sdl2:destroy-window (display-window display))))

(defun render (display)
  (render-frame)
  (sdl2:gl-swap-window (display-window display))
  (incf (clock-frame-count (clock =context=))))

(defun get-resolution ()
  (display-resolution (display =context=)))
