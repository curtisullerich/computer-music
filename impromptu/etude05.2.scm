(define drum-loop
   (lambda (beat)))
     (print beat)
     (if (*metre* beat 1)
       (begin
         (if (< (random) .4)
           (play-note (*metro* beat) btry *snare2* 100 (*metro* 'dur 1.0) 0)
           (play-note (*metro* beat) btry *hhopen1* 100 (*metro* 'dur 1.0) 0)
         )
         (if (< (random) .3)
           (fill1 (+ beat (random '( 1 1.5 2))))
         )
       )
     )
     
     (if (*metre* beat 2)
       (play-note (*metro* beat) btry *kick2* 100 (*metro* 'dur 1.0) 0)
     )
     (if (*metre* beat 3)
       (play-note (*metro* beat) btry *kick2* 100 (*metro* 'dur 1.0) 0)
     )
     (if (*metre* beat 4)
       (begin
         (play-note (*metro* (+ .5 beat)) btry *kick3* 100 (*metro* 'dur 1.0) 0)
         (fill3 beat)
       )
     )

     (if (< (random) .2)
         ;(fill2 (+ beat (random '( 2.5 3 3.5))))
     )
     
     (callback (*metro* (+ beat 3.95)) 'drum-loop (+ beat 1.0))
   )
)


(define metup)
   (lambda (tempo beat)
      (*metro* 'set-tempo (+ 1 (*metro* 'get-tempo)))
      (callback (*metro* (+ beat 2.9)) 'metup (+ tempo 3) (+ beat 3))
   )
)
(*metro* 'get-tempo)
(*metro* 'set-tempo 120)
(metup (*metro* 'get-tempo) (*metro* 'get-beat))

(play-note (now) btry 45 100 (*metro* 'dur 1) 0)
(define tomloop)
   (lambda (beat)
      (if (or (*metre* beat 4) (*metre* beat 1))
        ;(play-note (*metro* beat) btry (if (< (random) .3) *kick3* *kick4*) 70 (*metro* 'dur 1) 0)
      )
      (play-note (*metro* (+ 0 beat)) btry
        (random '(*kick1* *kick3* *hat1* *hhclosed1* *hhopen1* *hurt* *kick4* *hhopen2* *lowtom*));drum
        (- (random '(70 80 90 100 110)) -20) ;volume
        (*metro* 'dur 1.0)
        0
      )
      (let
         (
           (x (if (< (random) .85) .5 (if (< (random) .7) 1 1.5)))
         )
         (callback (*metro* (+ beat (- x .05))) 'tomloop (+ beat x))
      )
   )
)

(tomloop (*metro* 'get-beat))
(drum-loop (*metro* 'get-beat))
