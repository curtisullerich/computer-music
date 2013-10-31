(define piano (au:make-node "aumu" "dls " "appl"))

(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)

;; iterative sequence
(dotimes (i 8)
   (play-note (+ (now) (* i 5000)) piano (+ 60 i) 80 4000))

(let loop ((i 0))
   (play-note (+ (now) (* i 2500)) piano (+ 60 i) 80 4000)
   (if (< i 9) (loop (+ i 2))))
 
;; recursive major scale
(let loop (
           (scale '(0 2 4 5 7 9 11 12))
           (dur   '(22050 11025 11025 11025 22050 11025 11025 44100))
           (time 0)
          )
   (play-note (+ (now) time) piano (+ 60 (car scale)) 80 (car dur))
   (if (not (null? (cdr scale)))
       (loop (cdr scale) (cdr dur) (+ time (car dur)))))