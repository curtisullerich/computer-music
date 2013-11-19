(au:clear-graph)
(au:print-audiounits "aumu")
;(define piano (au:make-node "aumu" "dls " "appl"))
(define piano (au:make-node "aumu" "NiO5" "-NI-"))
(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
(au:open-view piano)

(define select-random
  (lambda (ls)
    (let ((len (length ls)))
      (list-ref ls (random len)))))


(define drums 
   (lambda (time duration)
      (print time)
      (play-note (*metro* time) piano 36 80 (*metro* 'dur duration) 2)
      (play-note (*metro* (+ time (* duration .5))) piano 68 80 (*metro* 'dur duration) 2)
      
      (if (or (*metre1* time 2.0) (*metre1* time 4.0))
          (begin
            (play-note (*metro* time) piano 40 80 (*metro* 'dur duration) 2)
          )
      )
                 
      (callback 
        (*metro* (+ time 1.0)) 
        'drums 
          (+ time duration) 
          duration
      )
   )
)
(drums (*metro* 'get-beat) 1.0)
(define *metre1* (make-metre '(4) 1.0))
   
;; create a metronome starting at 120 bpm
(define *metro* (make-metro 120))









