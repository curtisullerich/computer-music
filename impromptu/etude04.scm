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
  (lambda (beat duration root chord)
    (play-note (*metro* beat) ktk (+ root (car (pc:chord root chord))) 80 (*metro* 'dur duration) 0)
    (tenor beat duration root chord)
  )
)
; play half notes on 1 and 3, selected randomly from the diatonic major chord given the root note and scale degree played by the bass
(define tenor
  (lambda (beat duration root chord)
     (let 
      (
        (note1 (random (pc:chord root chord)))
        (note2 (random (pc:chord root chord)))
      )
      (alto beat duration root chord note1)
      (alto (+ beat 2.0) duration root chord note2)
      (play-note (*metro* beat) ktk (+ root note1) 80 (*metro* 'dur (/ duration 2)) 0)
      (play-note (*metro* (+ beat 2.0)) ktk (+ root note2) 80 (*metro* 'dur (/ duration 2)) 0)
     )
  )
)

(define alto
   (lambda (beat duration root chord tenornote)
      (let
        (
          (note1 (random (pc:chord root chord)))
          (note2 (random (pc:chord root chord)))
        )
        ;(soprano beat duration root chord note1)
        ;(soprano (+ beat 1.0) duration root chord note2)
        (play-note (*metro* beat) ktk (+ root note1 12) 80 (*metro* 'dur (/ duration 4)) 0)
        (play-note (*metro* (+ beat 1.0)) ktk (+ root note2 12) 80 (*metro* 'dur (/ duration 4)) 0)
      )
   )
)





; use a markov chain to select the next degree
(define nextchord
   (lambda (chord)
     ;(print degree)
     (random (cdr (assoc chord '((^ ^sus ^6)
                                  (^sus ^6 7)
                                  (^6 -sus o)
                                  (7 ^ -sus)
                                  (-sus ^ -)
                                  (- ^)
                                  (o ^)
                                 ))))
   )
)

(pc:relative 40 (random '(-1 1)) '(0 2 4 5 7 9 11))

(define soprano
   (lambda (beat duration root chord altonote)
      (let
         (
           (note1 (random (cdr (pc:diatonic root '^ chord))))
           (note2 (random (cdr (pc:diatonic root '^ chord))))
         )
         (play-note (*metro* beat) ktk (+ root note1 24) 80 (*metro* 'dur (/ duration 8)) 0)
         (play-note (*metro* (+ beat .5)) ktk (+ root note2 24) 80 (*metro* 'dur (/ duration 8)) 0)
      )
   )
)

(define melody
   (lambda (beat duration p))
      (play-note (*metro* beat) ktk p 80 (*metro* 'dur duration) 0)
      (callback 
        (*metro* (+ beat duration))
        'melody
        (+ beat duration)
        duration
        (pc:relative p (random '(-1 1)) '(0 2 4 5 7 9 11))
       )
   )
)

; main event loop. called once every four beats
(define loop 
   (lambda (beat duration root chord p)
      ;(print beat)
      (print chord)
      (bass beat duration root chord)
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
        root
        (nextchord chord)
        p
      )
   )
)
(melody (*metro* 'get-beat) 0.5 64)

(loop (*metro* 'get-beat) 4.0 40 '^ 40)









