; make sure that everything is disconnected
(au:clear-graph)
 (au:print-audiounits "aumu")
; setup simple au graph
; piano -> output
;(define piano (au:make-node "aumu" "dls " "appl"))
;(define piano (au:make-node "aumu" "NiMa" "-NI-"))
(define piano (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
(au:open-view piano)

(define pitches '(50 53 57 61 30 40 50 45 32))
;;(define pitches '(49 52 56 60 29 39 49 44 31))

;;(define pitches '(30 31 32 33 34 35 36 37))
;;(define pitches '(60 61 62 63 64 65 66 67))


(define select-random
  (lambda (ls)
    (let ((len (length ls)))
      (list-ref ls (random len)))))

; play a random note from plist len-x times
; a loop that schedules several events immediately
(define (loop1 time x len plist)
      (if (<= x len)
          (begin
            (play-note time piano (select-random plist)  80 (* 0.5 *second*))
            (loop1 (+ time (* *second* 0.15)) (+ x 1) len plist)
          )
      )
)
(+ 2 (* 3 (- 4 2)))

(loop1 (now) 0 100 pitches)

(play-note (now) piano (random 30 40) 80 *second*)

; a chord
(define chord
   (lambda (note)
      (play-note (now) piano (+ note 0) 80 *second*)
      (play-note (now) piano (+ note (random 3 5)) 80 *second*)
      (play-note (now) piano (+ note 7) 80 *second*)))

(chord (random 50 50))

; a single callback
(callback (+ (now) (* *second* 2)) 'chord 50)

; very simple loop that schedules repeated events using a callback
(define loop
  (lambda (time)
    (play-note time piano 60 80 *second* )
    (callback (+ time *second*) 'loop (+ time *second*))))



(+ (list-ref pitches (- 3 (random 6))) 50)
; loop that schedules more complex events using callbacks2


(define select-next-index
  (lambda (index lst)
    (let ((len (length lst)))
      (list-ref lst (random len)))))

(define loop 
  (lambda (time index)
    (define pitches '(0 4 7 9 11 12 16 19 21 23 24))
    ;(define pitches '(0 5 7 8 11 14 16 19 22))
     ;(define pitches '(0))
    (au:midi-out time piano *io:midi-cc* 0 10 (random 0 127))
    ;(au:midi-out time piano *io:midi-cc* 0 10 0)
     (let ((newindex (max 0 (min (- (length pitches) 1) (+ index (select-random '(-1 1) ))))))
          (print newindex)
             (play-note time piano 
                     (+ 
                        (list-ref pitches newindex)
                        45
                     )
               80 10000
             )
   ; (au:midi-out (+ time (/ *second* 8notest)) piano *io:midi-cc* 0 10 127)
    (if (eqv? (random 0 2) 0)
      ;(play-note (+ time (/ *second* 8)) piano (+ 50 (select-random pitches)) 80 10000)
    )
    (callback (+ time (/ *second* 8)) 'loop (+ time (/ *second* 8)) newindex)        
    );end of let
  )
)
(loop (now) 0)



