; linux Inotifiy wrapper

(require-extension miscmacros)

(foreign-declare "#include <sys/inotify.h>")

; Events
(define-foreign-variable IN_ACCESS int "IN_ACCESS")
(define-foreign-variable IN_ATTRIB int "IN_ATTRIB")
(define-foreign-variable IN_CLOSE_WRITE int "IN_CLOSE_WRITE")
(define-foreign-variable IN_CLOSE_NOWRITE int "IN_CLOSE_NOWRITE")
(define-foreign-variable IN_CREATE int "IN_CREATE")
(define-foreign-variable IN_DELETE int "IN_DELETE")
(define-foreign-variable IN_DELETE_SELF int "IN_DELETE_SELF")
(define-foreign-variable IN_MODIFY int "IN_MODIFY")
(define-foreign-variable IN_MOVE_SELF int "IN_MOVE_SELF")
(define-foreign-variable IN_MOVED_FROM int "IN_MOVED_FROM")
(define-foreign-variable IN_MOVED_TO int "IN_MOVED_TO")
(define-foreign-variable IN_OPEN int "IN_OPEN")
(define-foreign-variable IN_ALL_EVENTS int "IN_ALL_EVENTS")

; Other opts for inotify_add_watch
(define-foreign-variable IN_DONT_FOLLOW int "IN_DONT_FOLLOW")
(define-foreign-variable IN_MASK_ADD int "IN_MASK_ADD")
(define-foreign-variable IN_ONESHOT int "IN_ONESHOT")
(define-foreign-variable IN_ONLYDIR int "IN_ONLYDIR")

; Additional results from read()
(define-foreign-variable IN_IGNORED int "IN_IGNORED")
(define-foreign-variable IN_ISDIR int "IN_ISDIR")
(define-foreign-variable IN_Q_OVERFLOW int "IN_Q_OVERFLOW")
(define-foreign-variable IN_UNMOUNT int "IN_UNMOUNT")

; INotify funcs
(define inotify_init (foreign-lambda int "inotify_init"))
(define inotify_add_watch (foreign-lambda int "inotify_add_watch" int c-string int))
(define inotify_rm_watch (foreign-lambda int "inotify_rm_watch" int int))

(define-external (foo_callback (int wd) (int mask) (int cookie) (int len) (c-string name)) void
    (display "Name: ") (display name) (newline)
    (display "Mask: ") (display mask) (newline)
)

#>
    void inotify_read(int fd, void (*callback)(int, int, int, int, char*)) {
        int EVENT_SIZE = sizeof(struct inotify_event);
        int BUF_LEN = 1024*EVENT_SIZE+16;

        int length, i = 0;
        char buffer[BUF_LEN];

        length = read(fd, buffer, BUF_LEN);

        while (i < length) {
            struct inotify_event *event = (struct inotify_event *) &buffer[i];
            if (event->len) {
                foo_callback(event->wd, event->mask, event->cookie, event->len, event->name); // This works
                //callback(event->wd, event->mask, event->cookie, event->len, event->name); // This doesn't 
            }
            i += EVENT_SIZE + event->len;
        }
    }
<#


(define inotify_read
  (foreign-safe-lambda void "inotify_read" int (function void (int int int int c-string))))

; Main
(define fd (inotify_init))
(define wd (inotify_add_watch fd "/home/xin/Projects/chicken-stuff/test" IN_ALL_EVENTS))


(while #t
    (inotify_read fd foo_callback))

