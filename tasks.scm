(require-extension srfi-1)
(require-extension mailbox)

(define-syntax task
   (syntax-rules () 
     ((_ 'name ((var init) ...) . main_body) 
      (let ((var 'undefined) ...) ; Create dummy vars
        (let* (
              (var (let ((temp init)) (lambda () (set! var temp)))) ... ; set vars to functions that fill vars
              (main (lambda () . main_body)) ; main body func
              (channel (make-mailbox))       ; mailbox channel
              (thread (make-thread
                        (lambda ()
                          (print "Starting thread " (current-thread))
                          (let loop ((message (mailbox-receive! channel)))
                            (let ((func (car message)) (args (cdr message)))
                                (print (current-thread) ": func `" func "`, args: " args) 
                                (if (any (lambda (x) (eq? x func)) '(var ...)) 
                                  (func) #f)
                                (main))
                            (loop (mailbox-receive! channel)))) 'name)) ) 
                
          (var) ... ; Init vars
          (thread-start! thread)
          
          channel))))) 

(define zing (task 'zing (
                          (num (lambda () (print "Num: "))) )
                   (display "tick ") ))

(mailbox-send! zing (list 'message "1"))

(let mainloop ((i 10))
    (mailbox-send! zing (list 'num i))
    (thread-sleep! 1)
    (if (< 0 i) (mainloop (- i 1)) #f))

;(let loop ((threads (##sys#all-threads)))
;      (unless (null? threads)
;        (print "waiting for " (length threads) " threads to terminate")
;        (thread-join! (car threads))
;        (loop (##sys#all-threads))))
