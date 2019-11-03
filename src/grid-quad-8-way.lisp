(in-package #:pyx)

(defclass quad-grid/8-way (quad-grid) ())

(defmethod grid-cell-neighbor-directions ((grid quad-grid/8-way))
  (u:interleave (edge-directions grid)
                (corner-directions grid)))

(defmethod grid-cell-neighbor-offsets ((grid quad-grid/8-way))
  (vector (v2:vec 1 0)
          (v2:vec 1 -1)
          (v2:vec 0 -1)
          (v2:vec -1 -1)
          (v2:vec -1 0)
          (v2:vec -1 1)
          (v2:vec 0 1)
          (v2:vec 1 1)))

(defmethod grid-cell-distance ((grid quad-grid/8-way) cell1 cell2)
  (v2:with-components ((c (v2:abs (v2:- cell1 cell2))))
    (floor (max cx cy))))
