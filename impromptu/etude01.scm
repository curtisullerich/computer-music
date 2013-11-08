(au:clear-graph)
 (au:print-audiounits "aumu")
; setup simple au graph
; piano -> output
;(define piano (au:make-node "aumu" "dls " "appl"))
;(define piano (au:make-node "aumu" "NiMa" "-NI-"))
(define piano (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node piano 1 *au:output-node* 0)
(au:update-graph)
(au:open-view piano)
(define select-random
  (lambda (ls)
    (let ((len (length ls)))
      (list-ref ls (random len)))))

(define ostinato 
   (lambda (time note duration)
      (play-note (*metro* time) piano (+ 40 note) 80 (*metro* 'dur duration) 0)
      (callback 
        (*metro* (+ time (* .5 duration))) 
        'ostinato 
          (+ time duration) 
          (random (cdr (assoc note '((0 5 7)
                                     (7 0 5 11)
                                     (5 0)
                                     (11 0)
                                    ))))
          duration
      )
   )
)
   
(ostinato (*metro* 'get-beat) 0 4.0)

(define bells
   (lambda (time plist duration)
      (play-note (*metro* time)         piano (list-ref plist 0) 120 (*metro* 'dur 3.0) 2)
      (play-note (*metro* (+ time duration)) piano (list-ref plist 1) 120 (*metro* 'dur 2.5) 2)
      (play-note (*metro* (+ time (* 2 duration))) piano (list-ref plist 2) 120 (*metro* 'dur 2.0) 2)
   )
)
               
(define belltones
   (lambda (time)
      (bells time (select-random '((64 71 67) (66 60 62) (58 60 62) (40 52 64))) 0.5)
      (bells (+ time 2.0) (select-random '((64 71 67) (66 60 62) (58 60 62) (40 52 64))) 1.0)
      (callback
         (*metro* (+ time 4.0))
         'belltones
         (+ time 4.0)
      )
   )     
)

(belltones (*metro* 'get-beat))
   
(define loop 
  (lambda (time index pan velocity duration)
    (define pitches '(0 5 7 9 11 12 16 19 21 23 24))
    ;(define pitches '(0 5 7 8 11 14 16 19 22))
    ;(define pitches '(0))
    ;(au:midi-out time piano *io:midi-cc* 0 10 pan)
    ;(au:midi-out time piano *io:midi-cc* 0 10 (random 0 127))
    ;(au:midi-out time piano *io:midi-cc* 0 10 0)
    (let 
      (
        ;(newpan (max 1 (min 127 (+ pan (select-random '(-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10))))))
        (newindex (max 0 (min (- (length pitches) 1) (+ index (select-random '(-1 1) )))))
        (newvelocity (max 50 (min 50 (+ velocity (select-random '(-5 0 5))))))
        ;(newvelocity 80)
        ;(newindex 0)
        (newpan 50)
      )
      (print newindex)
      (play-note (*metro* time) piano 
        (+ 
          (list-ref pitches newindex)
          40
        )
        newvelocity 
        (*metro* 'dur duration)
        1
      )
   ;(au:midi-out (+ time (/ *second* 8notest)) piano *io:midi-cc* 0 10 127)
   ;(if (eqv? (random 0 2) 0)
     ;(play-note (+ time (/ *second* 8)) piano (+ 50 (select-random pitches)) 80 10000)
   ;)
   (callback (*metro* (+ time (* .5 duration))) 'loop (+ time duration) newindex newpan newvelocity duration)        
   );end of let
  )
)
(loop (*metro* 'get-beat) 0 50 80 .25)





;; create a metronome starting at 120 bpm
(define *metro* (make-metro 120))

;; beat loop with tempo shift
(define drum-loop
   (lambda (time duration)))
      (*metro* 'set-tempo (+ 120 (* 40 (cos (* .25 3.141592 time)))))
      ;(*metro* 'set-tempo 180)
      (play-note (*metro* time) piano 60 80 (*metro* 'dur duration))
      (callback (*metro* (+ time (* .5 duration))) 'drum-loop (+ time duration)
                (random (list 0.5)))))
 
(drum-loop (*metro* 'get-beat) 0.25)




