(use posix)
(use srfi-1)

(define (find-by-value? val aList)
    (any (lambda (x) (equal? x val)) aList))

(define (walk dir callback)
  (cond ((directory? dir)
         (let* ((dirlist (directory dir))
                (fulldirlist (map (lambda (new_bit) (make-pathname dir new_bit)) dirlist)))
           (call/cc (lambda (break)
               (callback dir dirlist break)
               (map (lambda (dir) (walk dir callback)) fulldirlist)))))))

