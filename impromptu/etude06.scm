
(define pc-from-degree
   (lambda (degree)
     (car (cdr (assoc degree *pc:diatonic-minor*)))
   )
)

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
   (lambda (time plist duration offset len)
      (play-note (*metro* time)         ktk (+ offset (list-ref plist 0)) 120 (*metro* 'dur len) 1)
      (play-note (*metro* (+ time duration)) ktk (+ offset (list-ref plist 1)) 120 (*metro* 'dur (- len duration)) 1)
      (play-note (*metro* (+ time (* 2 duration))) ktk (+ offset (list-ref plist 2)) 120 (*metro* 'dur (- len (* 2 duration))) 1)
   )
)

(64 71 67) (66 60 62) (58 61 63) (40 52 64)
(define tones
   (lambda (time len root dur)))
      (bells time (random '((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))) dur root len)
      (callback
         (*metro* (+ time (- len 0.05)))
         'tones
         (+ time len) len root dur
      )
   )     
)

(64 71 67) (67 58 62) (58 61 63) (40 52 64)
(help *metro*)

(tones (*metro* 'get-beat) 10 64 1.0)
(tones (*metro* 'get-beat) 15 76 4.0)

(tones (*metro* 'get-beat) 20 52 0.5)