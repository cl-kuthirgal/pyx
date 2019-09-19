(in-package #:pyx)

(defclass spritesheet ()
  ((%spec :reader spec
          :initarg :spec)
   (%sprites :reader sprites
             :initform (u:dict #'equalp))
   (%texture-id :reader texture-id
                :initarg :texture-id)
   (%vao :reader vao
         :initarg :vao)))

(defun write-spritesheet-buffer (buffer spritesheet)
  (with-slots (%spec %sprites) spritesheet
    (loop :with count = (length %spec)
          :with pos = (make-array count)
          :with size = (make-array count)
          :for sprite :in %spec
          :for i :from 0
          :do (destructuring-bind (&key id x y w h) sprite
                (when (and id x y w h)
                  (setf (aref pos i) (v2:vec x y)
                        (aref size i) (v2:vec w h)
                        (u:href %sprites id) i)))
          :finally (shadow:write-buffer-path buffer :pos pos)
                   (shadow:write-buffer-path buffer :size size))))

(defun make-spritesheet (image-path)
  (cache-lookup :spritesheet image-path
    (let* ((spec-file (make-pathname :defaults image-path :type "spec"))
           (spec (u:safe-read-file-form
                  (resolve-asset-path spec-file)))
           (texture (load-texture image-path))
           (spritesheet (make-instance 'spritesheet
                                       :spec spec
                                       :texture-id (id texture)
                                       :vao (gl:gen-vertex-array))))
      (make-shader-buffer :spritesheet 'umbra.sprite:sprite)
      (write-spritesheet-buffer :spritesheet spritesheet)
      spritesheet)))
