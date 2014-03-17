;; Bight
;; Curtis Ullerich - curtisullerich.com
;; March 16th, 2014

(define bells
   (lambda (time plist duration offset len inst)
      (play-note (*metro* time)                    ktk (+ offset (list-ref plist 0)) (random '(90 100 110)) (*metro* 'dur len) inst)
      (play-note (*metro* (+ duration time))        ktk (+ offset (list-ref plist 1)) (random '(90 100 110)) (*metro* 'dur (- len duration)) inst)
      (play-note (*metro* (+ (* 2 duration) time))  ktk (+ offset (list-ref plist 2)) (random '(90 100 110)) (*metro* 'dur (- len (* 2 duration))) inst)
      )
   )
(define tones
   (lambda (time len root dur inst)
      (bells time (random '((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))) dur root len inst)
      (if (<> inst 6)
        (callback (*metro* (+ time (- len 0.05))) 'tones (+ time len) len root dur inst)
      )
   )
)
(tones (*metro* 'get-beat) 10 52 1.0 6)
(tones (*metro* 'get-beat) 15 64 4.0 6)
(tones (*metro* 'get-beat) 20 40 0.5 7)
(define bass)
   (lambda (beat)
      (let
        ((o (+ 40 (random '(0 2 3 5 7 -4)))))
;        (play-note (*metro* beat) ktk o 40 (*metro* 'dur .25) 0)
;        (play-note (*metro* beat) ktk o 60 (*metro* 'dur .25) 7)
      )
      (let
         ((b (random '(1/4 1/4 1/4 1/4 1/4 1/4 1/2))))
         (callback (*metro* (+ beat (- b 0.05))) 'bass (+ beat b))
     )
      
      )
   )
(define bung)
   (lambda (time len root dur)
        (play-note (*metro* time) ktk root 110 (*metro* 'dur len) 7)
        (callback
         (*metro* (+ time (- len 0.05)))
         'bung
         (+ time len) len root dur
        )     
   )
)
(bung (*metro* 'get-beat) 11 40 1)

(bass (*metro* 'get-beat))
(play-note (now) btry 35 120 (*metro* 'dur 1) 0)
(define tomloop)
   (lambda (beat)
      (if (or (*metre* beat 4) (*metre* beat 1))
         (play-note (*metro* beat) btry (if (< (random) .1) 35 36) 100 (*metro* 'dur 1) 0)
      )
      (play-note (*metro* (+ 0 beat)) btry
        (random '( 39 41 42 42 42 43 44 44 45 47 48 50 35 36 52)) ;drums
        (- (random '(70 80 90 100 110)) -0) ;volume
        (*metro* 'dur 1.0)
        0
      )
      (let
         ((x (if (< (random) .1) .5 (if (< (random) .7) 1 1.5))))
         (callback (*metro* (+ beat (- x .05))) 'tomloop (+ beat x))
      )
   )
)
(tomloop (*metro* 'get-beat))
