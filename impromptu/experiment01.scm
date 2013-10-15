; make sure that everything is disconnected
(au:clear-graph)
 
; setup simple au graph
; piano -> output
(define piano (au:make-node "aumu" "dls " "appl"))
(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
 
(define pitches '(50 54 57 61 30 40 50 45 32))

(define select-random
  (lambda (ls)
    (let ((len (length ls)))         ;; find out how long the list is
      (list-ref ls (random len)))))

(define (loop time x len plist)
      (if (<= x len)
          (begin
            (play-note time piano (select-random plist)  80 (* .5 *second*))
            (loop (+ time (* *second* 0.15)) (+ x 1) len plist)
          )
      )
)
;(play-note (now) piano 60 80 (* 1.0 *second*))


(loop (now) 0 100 pitches)