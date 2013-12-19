; use a markov chain to select the next chord
(define nextchord
   (lambda (chord)
     (random (cdr (assoc chord '( (i vi-7 vii7 iv i^7 iv^7 v-)
                                  (i^7 vii7 v-)
                                  (iv i i^7)
                                  (iv^7 iv i i^7)                                       
                                  (v- iv iv^7)
                                  (vi-7 i)
                                  (vii7 i)))))
   )
)

(for-each (lambda (p)
      (play-note (now) ktk (+ 60 p) 80 (*metro* 'dur 4.0) 0))
          (pc:diatonic 0 '- 'i))

; main event loop. called once every four beats
(define bass-loop 
   (lambda (beat duration chord root)
      (print chord)
      (play-note (*metro* beat) ktk (+ root (pc-from-degree (car (assoc chord *pc:diatonic-minor*)))) 100 (*metro* 'dur duration) 0)
      ;(if (or (*metre1* time 1.0))
      ;    (begin
      ;      (play-note (*metro* time) piano 40 80 (*metro* 'dur duration) 2)
      ;    )
      ;)
      (callback 
        (*metro* (+ beat (- duration .1))) 
        'bass-loop 
        (+ beat duration) 
        duration
        (nextchord chord)
        root
     )
   )
)
(bass-loop (*metro* 'get-beat) 8.0 'i 40)
(pc:chord 40 'i)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define bells
   (lambda (time plist duration offset len inst)
      (play-note (*metro* time)         ktk (+ offset (list-ref plist 0)) (random '(90 100 110)) (*metro* 'dur len) inst)
      (play-note (*metro* (+ time duration)) ktk (+ offset (list-ref plist 1)) (random '(90 100 110)) (*metro* 'dur (- len duration)) inst)
      (play-note (*metro* (+ time (* 2 duration))) ktk (+ offset (list-ref plist 2)) (random '(90 100 110)) (*metro* 'dur (- len (* 2 duration))) inst)
   )
)

(64 71 67) (66 60 62) (58 61 63) (40 52 64)
(define tones)
   (lambda (time len root dur inst)
      (bells time (random '((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))) dur root len inst)
      (if (<> inst -1)
        (callback
         (*metro* (+ time (- len 0.05)))
         'tones
         (+ time len) len root dur
         inst
        )
      )
   )      
)

(64 71 67) (67 58 62) (58 61 63) (40 52 64)
(tones (*metro* 'get-beat) 10 52 1.0 6)
(tones (*metro* 'get-beat) 15 64 4.0 4)
(tones (*metro* 'get-beat) 20 40 0.5 5)

(define bung)
   (lambda (time len root dur)
        (play-note (*metro* time) ktk root 110 (*metro* 'dur len) 6)
        (callback
         (*metro* (+ time (- len 0.05)))
         'bung
         (+ time len) len root dur
        )     
   )
)

(bung (*metro* 'get-beat) 11 52 1)

(define bass
   (lambda (beat)
      (play-note (*metro* beat) ktk (+ (random '(-2 0 2 0 3 7 7 -4 12)) 52) 120 (*metro* 'dur .25) 5)
      (let
         ( 
           (b (random '(1/2 1/2 1/2 1/2 1/2 1/2 2/2)))
         )
         (print b)
         (callback (*metro* (+ beat (- b 0.05))) 'bass (+ beat b))
     )
   )
)
(bass (*metro* 'get-beat))

      
      
