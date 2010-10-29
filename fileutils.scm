(use posix)
(use srfi-1)

(define (find-by-value? val aList)
    (any (lambda (x) (equal? x val)) aList))

; Walks directory dir and calls callback for each folder found.
; callback should take 3 arguments:
;  * dir - the directory currently being walked
;  * dirlist - the list of files in that directory
;  * break - a continuation that can be called to prevent further recursion into dir

(define (walk dir callback)
  (cond ((directory? dir)
         (let* ((dirlist (directory dir))
                (fulldirlist (map (lambda (new_bit) (make-pathname dir new_bit)) dirlist)))
           (call/cc (lambda (break)
               (callback dir dirlist break)
               (map (lambda (dir) (walk dir callback)) fulldirlist)))))))

