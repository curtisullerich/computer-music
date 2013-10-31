(define piano (au:make-node "aumu" "dls " "appl"))

(au:connect-node piano 0 *au:output-node* 0)
(au:update-graph)
(au:midi-out (now) piano *io:midi-on* 0 60 80)
(au:midi-out (+ (now) 10000) piano *io:midi-off* 0 60 0)
(au:print-params piano *au:global-scope*)


(au:clear-graph)

(define piano1 (au:make-node "aumu" "dls " "appl"))
(define filter1 (au:make-node "aufx" "filt" "appl"))
(define piano2 (au:make-node "aumu" "dls " "appl"))
(define filter2 (au:make-node "aufx" "filt" "appl"))
(define merger (au:make-node "aufc" "merg" "appl"))
 
(au:connect-node piano1 0 filter1 0)
(au:connect-node piano2 0 filter2 0)
(au:connect-node filter1 0 merger 0)
(au:connect-node filter2 0 merger 1)
(au:connect-node merger 0 *au:output-node* 0)
 
(au:update-graph)
(au:print-graph)
 
(play-note (now) piano1 60 80 10000)
(play-note (now) piano2 72 80 10000)
(start-audio-capture "/tmp/test.aif" 2)
(stop-audio-capture)

