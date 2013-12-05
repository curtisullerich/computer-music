(au:clear-graph)
(au:print-audiounits "aumu")
;(define piano (au:make-node "aumu" "dls " "appl"))
(define piano (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
(au:open-view piano)

(define drums 
   (lambda (time duration)))
      ;(print time)
      ;(play-note (*metro2* time) ktk 36 80 (*metro2* 'dur duration) 2)
      (play-note (*metro2* (+ time (* duration .5))) ktk 68 80 (*metro2* 'dur duration) 2)

      (if (or (*metre1* time 2.0) (*metre1* time 4.0))
          (begin
            ;(play-note (*metro2* time) ktk 40 80 (*metro2* 'dur duration) 2)
          )
      )
      
      (callback 
        (*metro2* (+ time 1.0)) 
        'drums 
          (+ time duration) 
          duration
      )
   )
)
(define drums2 
   (lambda (time duration)))
      ;(print time)
      (play-note (*metro* time) ktk 36 80 (*metro* 'dur duration) 2)
      ;(play-note (*metro* (+ time (* duration .5))) ktk 68 80 (*metro* 'dur duration) 2)
      
      (if (or (*metre2* time 2.0) (*metre2* time 4.0))
          (begin
            (play-note (*metro* time) ktk 40 80 (*metro* 'dur duration) 2)
          )
      )
                 
      (callback 
        (*metro* (+ time 1.0)) 
        'drums2 
          (+ time duration) 
          duration
      )
   )
)
(drums (*metro* 'get-beat) 1.0)
(drums2 (*metro2* 'get-beat) 1.0)
(define *metre1* (make-metre '(2) 1.0))
(define *metre2* (make-metre '(3 2 3) 1.0))
   
;; create a metronome starting at 120 bpm
(define *metro* (make-metro 99))
(define *metro2* (make-metro 100))









