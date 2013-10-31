;; up 7 semitones or a perfect fifth
(map (lambda (p)
        (pc:? (+ p 7) '(0 2 4 5 7 9 11)))
     (list 60 62 64 65 67 69 71))
 
;; up 5 semitones or a perfect forth
(map (lambda (p)
        (pc:? (+ p 5) '(0 2 4 5 7 9 11)))
     (list 60 62 64 65 67 69 71))
 
;; up 4 semitones or a major third
(map (lambda (p)
        (pc:? (+ p 4) '(0 2 4 5 7 9 11)))
     (list 60 62 64 65 67 69 71))

(define crazy-chord
   (lambda (time)
      (play-note time piano (pc:random 24 97 '(0 4 7)) 80 500)
      (callback (+ time 1000) 'crazy-chord (+ time 2000))))
 
(crazy-chord (now))

;; C-major and repeat
(define chords
   (lambda (time)
      (for-each (lambda (p)                  
                   (play-note time piano p 80 10000))
                (pc:make-chord 20 100 3 '(0 4 7)))
      (callback (+ time 10000) 'chords (+ time 11025))))
 
(chords (now))

;; I IV V
(define chords
   (lambda (time chord)
      (for-each (lambda (p)                  
                   (play-note time piano p 80 10000))
                (pc:make-chord 48 90 3 chord))
      (callback (+ time 10000) 'chords (+ time 11025)
                (if (> (random) .8)
                    (random '((0 4 7) (5 9 0) (7 11 2)))
                    chord))))
 
(chords (now) '(0 4 7))


; markov chord progression I ii iii IV V vi vii
(define progression
   (lambda (time degree)
      (for-each (lambda (p)
                   (play-note time piano p 80 40000))
                (pc:make-chord 48 77 5 (pc:diatonic 0 '^ degree)))
      (callback (+ time 40000) 'progression (+ time 44100)
                (random (cdr (assoc degree '((i iv v iii vi)
                                             (ii v vii)
                                             (iii vi)
                                             (iv v ii vii i)                                            
                                             (v i vi)
                                             (vii v i)
                                             (vi ii))))))))
(progression (now) 'i)

;; mordant  
(define play-note-mord
   (lambda (time inst pitch vol duration pc)
      (play-note (- time 5000) inst pitch (- vol 10) 2500)
      (play-note (- time 2500) inst (pc:relative pitch 1 pc) (- vol 10) 2500)
      (play-note time inst pitch vol (- duration 5000))))
 
;; markov chord progression I ii iii IV V vi vii
(define progression
   (lambda (time degree)
      (let ((dur (if (member degree '(i iv)) 88200 44100)))
         (for-each (lambda (p)
                      (if (and (> p 70) (> (random) .7))
                          (play-note-mord time piano p
                                          (random 70 80)
                                          (* .9 dur) '(0 2 4 5 7 9 11))                  
                          (play-note time harpsichord p (random 70 80) (* .9 dur))))
                   (pc:make-chord 40 78 4 (pc:diatonic 0 '^ degree)))
         (callback (+ time (* .9 dur)) 'progression (+ time dur)
                   (random (cdr (assoc degree '((i iv v iii vi)
                                                (ii v vii)
                                                (iii vi)
                                                (iv v ii vii i)                                            
                                                (v i vi)
                                                (vii v i)
                                                (vi ii)
                                                )
                                       )
                                )
                           )
                   )
         )
      )
   )
 
(progression (now) 'i)
 