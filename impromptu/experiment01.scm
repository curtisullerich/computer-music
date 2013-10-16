; make sure that everything is disconnected
(au:clear-graph)
 
; setup simple au graph
; piano -> output
(define piano (au:make-node "aumu" "dls " "appl"))
(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
 
(define pitches '(50 53 57 61 30 40 50 45 32))
;;(define pitches '(49 52 56 60 29 39 49 44 31))

;;(define pitches '(30 31 32 33 34 35 36 37))
;;(define pitches '(60 61 62 63 64 65 66 67))

(define select-random
  (lambda (ls)
    (let ((len (length ls)))
      (list-ref ls (random len)))))

;; play a random note from plist len-x times
(define (loop time x len plist)
      (if (<= x len)
          (begin
            (play-note time piano (select-random plist)  80 (* 0.5 *second*))
            (loop (+ time (* *second* 0.15)) (+ x 1) len plist)
          )
      )
)
(+ 2 (* 3 (- 4 2)))

(loop (now) 0 1000 pitches)


(define piano (au:make-node "aumu" "dls " "appl"))

(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
(play-note (now) piano (random 30 40) 80 *second*)

(define chord
   (lambda (note)
      (play-note (now) piano (+ note 0) 80 *second*)
      (play-note (now) piano (+ note (random 3 5)) 80 *second*)
      (play-note (now) piano (+ note 7) 80 *second*)))

(chord (random 50 50))

(define loop 
  (lambda (time plist)
    (au:midi-out time piano *io:midi-cc* 0 10 (random 0 127))
    ;;(au:midi-out time piano *io:midi-cc* 0 10 0)
    (play-note time piano (select-random plist) 80 1.0)
    ;;(au:midi-out (+ time (/ *second* 8)) piano *io:midi-cc* 0 10 127)
    (if (eqv? (random 0 2) 0)
      (play-note (+ time (/ *second* 8)) piano (select-random plist) 80 1.0)
    )
    (callback (+ time (/ *second* 4)) 'loop (+ time (/ *second* 4)) plist)
  )
)

(define loop
  (lambda (time)
    (play-note time piano 60 80 *second* )
    (callback (+ time *second*) 'loop (+ time *second*))))
  
(loop (now) pitches)
(callback (+ (now) (* *second* 2)) 'chord 50)
