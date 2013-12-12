(au:clear-graph)
(au:print-audiounits "aumu")
; setup simple au graph
; ktk -> output
;(define ktk (au:make-node "aumu" "dls " "appl"))
;(define massive (au:make-node "aumu" "NiMa" "-NI-"))
(define ktk (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node ktk 0 *au:output-node* 0)
(au:update-graph)
(au:open-view ktk)

(define bass 
   (lambda (time note duration)
      ;(print time)
      (play-note (*metro* time) ktk (+ 40 note) 100 (*metro* 'dur duration) 0)
      (callback 
        (*metro* (+ time (* .5 duration))) 
        'bass 
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
(bass (*metro* 'get-beat) 0 4.0)


(define single
   (lambda (time note duration)
      (print "single")
      (play-note (*metro* time) ktk note 80 (*metro* 'dur duration) 0)
    )
)

(define double
   (lambda (time notes duration)
      (print "double")
      (play-note (*metro* time)              ktk (+ 0 (list-ref notes 0)) 120 (*metro* 'dur 3.0) 0)
      (play-note (*metro* (+ time (* .75 duration))) ktk (+ 0 (list-ref notes 1)) 120 (*metro* 'dur 1.0) 0)
   )
)


(define clarinet 
   (lambda (time note duration)
      ;(print time)
      (if 
         (< .5 (random))
          (single time 50 duration)
          (double time '(47 48) duration)
      )
      ;(double time '(47 44) duration)
      (callback 
        (*metro* (+ time (* .5 duration))) 
        'clarinet 
          (+ time duration) 
          ;(random (cdr (assoc note '((0 5 7)
          ;                           (7 0 5 11)
          ;                           (5 0)
          ;                           (11 0)
          ;                          ))))
          0
          duration
      )
   )
)
(clarinet (*metro* 'get-beat) 0 4.0)


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
   
(define loop 
  (lambda (time index pan velocity duration)
    (define pitches '(0 5 7 9 11 12 16 19 21 23 24))
    ;(define pitches '(0 5 7 8 11 14 16 19 22))
    ;(define pitches '(0))
    ;(au:midi-out time ktk *io:midi-cc* 0 10 pan)
    ;(au:midi-out time ktk *io:midi-cc* 0 10 (random 0 127))
    ;(au:midi-out time ktk *io:midi-cc* 0 10 0)
    (let 
      (
        ;(newpan (max 1 (min 127 (+ pan (select-random '(-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10))))))
        (newindex (max 0 (min (- (length pitches) 1) (+ index (random '(-1 1) )))))
        (newvelocity (max 50 (min 50 (+ velocity (random '(-5 0 5))))))
        ;(newvelocity 80)
        ;(newindex 0)
        (newpan 50)
      )
      ;(print newindex)
      (play-note (*metro* time) ktk 
        (+ 
          (list-ref pitches newindex)
          40
        )
        newvelocity 
        (*metro* 'dur duration)
        1
      )
   ;(au:midi-out (+ time (/ *second* 8notest)) ktk *io:midi-cc* 0 10 127)
   ;(if (eqv? (random 0 2) 0)
     ;(play-note (+ time (/ *second* 8)) ktk (+ 50 (select-random pitches)) 80 10000)
   ;)
   (callback (*metro* (+ time (* .5 duration))) 'loop (+ time duration) newindex newpan newvelocity duration)        
   );end of let
  )
)
(loop (*metro* 'get-beat) 0 50 80 .25)

;; create a metronome starting at 120 bpm
(define *metro* (make-metro 110))

;; beat loop with tempo shift
(define drum-loop
   (lambda (time duration)
      (*metro* 'set-tempo (+ 120 (* 40 (cos (* .25 3.141592 time)))))
      ;(*metro* 'set-tempo 180)
      (play-note (*metro* time) ktk 60 80 (*metro* 'dur duration))
      (callback (*metro* (+ time (* .5 duration))) 'drum-loop (+ time duration)
                (random (list 0.5)))))
 
(drum-loop (*metro* 'get-beat) 0.25)




