(define loop
   (lambda (beat)
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
     
     (callback (*metro* (+ beat 3.95)) 'loop (+ beat 1.0))
   )
)

(play-note (now) btry *kick2* 100 (*metro* 'dur 1) 0)
(define tomloop
   (lambda (beat)
      ;(print beat)
      (if (*metre* beat 1)
          (play-note (*metro* beat) btry (if (< (random) .2) *kick2* *kick1*) 120 (*metro* 'dur 1) 0)
      )
      (play-note (*metro* beat) btry
         (random '(36 37 39 40 41 42 45 46 50 61))
         (- (random '(70 80 100 110)) 0)
         (*metro* 'dur 1.0)
         0
      )
      (let
         (
           (x (if (< (random) .7) 0.5 1))
         )
         (callback (*metro* (+ beat (- x .05))) 'tomloop (+ beat x))
      )
   )
)

(tomloop (*metro* 'get-beat))
(help *metre*)
(define *metre* (make-metre '(3 2) 1.0))
(loop (*metro* 'get-beat))
