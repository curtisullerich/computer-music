(au:clear-graph)
(au:print-audiounits "aumu")
(define ktk (au:make-node "aumu" "NiO5" "-NI-"))
(define btry (au:make-node "aumu" "NBa3" "-NI-"))
(define merger (au:make-node "aufc" "merg" "appl"))
(au:connect-node merger 0 *au:output-node* 0)
(au:connect-node ktk 0 merger 1)
(au:connect-node btry 0 merger 0)
;(au:connect-node btry 0 *au:output-node* 0)
(au:update-graph)
(au:open-view btry)
(au:open-view ktk)
(au:print-graph)

(define *kick1* 36)
(define *kick2* 45)
(define *kick3* 37)
(define *kick4* 46)
(define *hhclosed1* 40)
(define *hhopen1* 41)
(define *hurt* 42)
(define *nasty* 43)
(define *pok* 44)
(define *distoor* 47)
(define *hat2* 48)
(define *hhclosed2* 49)
(define *hhopen2* 50)
(define *knife* 51)
(define *pain* 52)
(define *punch* 53)
(define *skri* 54)
(define *smock* 55)
(define *snare* 56)
(define *snare2* 57)
(define *snare3* 58)
(define *tjak* 59)
(define *hitom* 60)
(define *lowtom* 61)
(define *midtom* 62)
(define *varisnare* 63)
(define *violent* 64)
(define *netall* 65)

(define *metro* (make-metro 120))
(define *metre* (make-metre '(4) 1.0))

(define pc-from-degree
   (lambda (degree)
     (car (cdr (assoc degree *pc:diatonic-minor*)))
   )
)

;for bells
;'((0 -7 -4) (0 7 3) (0 -7 -2) (-7 0 -4) (5 0 3) (-2 -7 3) (3 -2 0))