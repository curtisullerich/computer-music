
(define pc-from-degree
   (lambda (degree)
     (car (cdr (assoc degree *pc:diatonic-major*)))
   )
)

; use a markov chain to select the next degree
(define nextdegree
   (lambda (chord)
     ;(print degree)
     (random (cdr (assoc chord '( (i )
                                  (i^7 vii7 v-)
                                  (iv i i^7)
                                  (iv^7 iv i i^7)                                       
                                  (v- iv iv^7)
                                  (vi-7 i)
                                  (vii7 i)))))
   )
)

(define bass
  (lambda (beat duration root chord)
     (print chord)
    (play-note (*metro* beat) ktk (+ root (car (pc:chord root chord))) 80 (*metro* 'dur duration) 0)
    (tenor beat duration root chord)
  )
)


(pc:diatonic 0 '- 'i)

(for-each (lambda (p)
      (play-note (now) ktk (+ 60 p) 80 (*metro* 'dur 4.0) 0))
          (pc:diatonic 0 '- 'i))

; main event loop. called once every four beats
(define loop 
   (lambda (beat duration degree root)
      ;(print beat)
      (bass beat duration root degree)
      ;(if (or (*metre1* time 1.0))
      ;    (begin
      ;      (play-note (*metro* time) piano 40 80 (*metro* 'dur duration) 2)
      ;    )
      ;)
      (callback 
        (*metro* (+ beat 4.0)) 
        'loop 
        (+ beat duration) 
        duration
        (nextdegree degree)
        root
     )
   )
)
(loop (*metro* 'get-beat) 4.0 'i 40)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define bells
   (lambda (time plist duration offset)
      (play-note (*metro* time)         ktk (+ offset (list-ref plist 0)) 120 (*metro* 'dur (* 4 duration)) 1)
      (play-note (*metro* (+ time duration)) ktk (+ offset (list-ref plist 1)) 120 (*metro* 'dur (* 3 duration)) 1)
      (play-note (*metro* (+ time (* 2 duration))) ktk (+ offset (list-ref plist 2)) 120 (*metro* 'dur (* 2 duration)) 1)
   )
)

(64 71 67) (66 60 62) (58 61 63) (40 52 64)
(define eighths
   (lambda (time)))
      (bells time (random '((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))) 0.5 72)
      (callback
         (*metro* (+ time 4.0))
         'eighths
         (+ time 7.0)
      )
   )     
)


(64 71 67) (67 58 62) (58 61 63) (40 52 64)
(define halves
   (lambda (time)))
      (bells (+ time 2.0) (random '((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))) 1.0 60)
      (callback
         (*metro* (+ time 4.0))
         'halves
         (+ time 5.0)
      )
   )     
)
(help *metro*)

(halves (*metro* 'get-beat))
(eighths (*metro* 'get-beat))