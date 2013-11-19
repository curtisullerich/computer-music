(au:clear-graph)
(au:print-audiounits "aumu")
;(define piano (au:make-node "aumu" "dls " "appl"))
(define ktk (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node ktk 0 *au:output-node* 0)
(au:update-graph)
(au:open-view ktk)

(define *metre1* (make-metre '(4) 1.0)) 
(define *metro* (make-metro 80))

(define pc-from-degree
   (lambda (degree)
     (car (cdr (assoc degree *pc:diatonic-major*)))
   )
)

(pc:diatonic 50 '^ 'iii)

; play the current scale degree
(define bass
  (lambda (beat duration root degree)
    (play-note (*metro* beat) ktk (+ root (pc-from-degree degree)) 80 (*metro* 'dur duration) 0)
    (tenor beat duration root degree)
  )
)

; play half notes on 1 and 3, selected randomly from the diatonic major chord given the root note and scale degree played by the bass
(define tenor
  (lambda (beat duration root degree)
     (let 
      (
        (note1 (random (cdr (pc:diatonic root '^ degree))))
        (note2 (random (cdr (pc:diatonic root '^ degree))))
      )
      (play-note (*metro* beat) ktk (+ root note1) 80 (*metro* 'dur (/ duration 2)) 0)
      (play-note (*metro* (+ beat 2.0)) ktk (+ root note2) 80 (*metro* 'dur (/ duration 2)) 0)
      (alto beat duration root degree note1)
      (alto (+ beat 2.0) duration root degree note2)
     )
  )
)

(define soprano
   (lambda (beat duration root degree altonote)
      (let
         (
           (note1 (random (cdr (pc:diatonic root '^ degree))))
           (note2 (random (cdr (pc:diatonic root '^ degree))))
         )
         (play-note (*metro* beat) ktk (+ root note1 24) 80 (*metro* 'dur (/ duration 8)) 0)
         (play-note (*metro* (+ beat .5)) ktk (+ root note2 24) 80 (*metro* 'dur (/ duration 8)) 0)
      )
   )
)

(define alto
   (lambda (beat duration root degree tenornote)
      (let
         (
           (note1 (random (cdr (pc:diatonic root '^ degree))))
           (note2 (random (cdr (pc:diatonic root '^ degree))))
         )
         (play-note (*metro* beat) ktk (+ root note1 12) 80 (*metro* 'dur (/ duration 4)) 0)
         (play-note (*metro* (+ beat 1.0)) ktk (+ root note2 12) 80 (*metro* 'dur (/ duration 4)) 0)
        (soprano beat duration root degree note1)
        (soprano (+ beat 1.0) duration root degree note2)
      )
   )
)

; use a markov chain to select the next degree
(define nextdegree
   (lambda (chord)
     ;(print degree)
     (random (cdr (assoc chord '((i iv v iii vi)
                                  (ii v vii)
                                  (iii vi)
                                  (iv v ii vii i)                                            
                                  (v i vi)
                                  (vii v i)
                                  (vi ii)))))
   )
)

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









