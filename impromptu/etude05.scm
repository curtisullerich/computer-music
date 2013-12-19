(play-note (now) btry *kick4* 60 (*metro* 'dur 1.0) 0)

(define fill1
   (lambda (beat)
     (print "fill1")
     (print beat)
     (play-note (*metro* (+ 0 beat)) btry *hitom* 100 (*metro* 'dur 1.0) 0)
     (play-note (*metro* (+ .333 beat)) btry *midtom* 100 (*metro* 'dur 1.0) 0)
     (play-note (*metro* (+ .666 beat)) btry *lowtom* 100 (*metro* 'dur 1.0) 0)
   )
)

(define fill2
   (lambda (beat)
      (for-each 
        (lambda (b)
          (play-note (*metro* (+ b beat)) btry *punch* 100 (*metro* 'dur 1.0) 0)
        )
        '(0 .666 1.333)
      )
   )
)
(define fill3
   (lambda (beat)
      (print beat)
      (for-each 
        (lambda (b)
          (play-note (*metro* (+ b beat)) btry (random '(*hurt* *nasty*)) 80 (*metro* 'dur .05) 0)
        )
        '(0 .2 .4 .6 .8)
      )
   )
)

(define drum-loop)
   (lambda (beat)
     (print beat)
     (if (< (random) .4)
         (play-note (*metro* beat) btry *snare2* 110 (*metro* 'dur 1.0) 0)
         (play-note (*metro* beat) btry *hhopen1* 110 (*metro* 'dur 1.0) 0)
     )
     
     (play-note (*metro* (+ 1 beat)) btry *kick1* 110 (*metro* 'dur 1.0) 0)
     (if (< (random) .3)
         (play-note (*metro* (+ 1.5 beat)) btry *kick2* 110 (*metro* 'dur 1.0) 0)
     )
     (play-note (*metro* (+ 2 beat)) btry *kick4* 110 (*metro* 'dur 1.0) 0)
     (play-note (*metro* (+ 3.5 beat)) btry *kick3* 110 (*metro* 'dur 1.0) 0)
     ;(if (< (random) .3)
     ;    (fill1 (+ beat (random '( 1 1.5 2))))
     ;    (if (< (random) .3)
     ;      (fill2 (+ beat (random '( 2.5 3 3.5))))
     ;      (if (< (random) .4)
     ;        (fill3 (+ beat 4))
     ;      )
     ;    )
     ;)
      
     (callback (*metro* (+ beat 3.95)) 'drum-loop (+ beat 4.0))
   )
)

(drum-loop (*metro* 'get-beat))

