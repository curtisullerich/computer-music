(define *af:hat* 82)
(define *af:snare* 53)
(define *af:kick* 54)
(define *af:congolow* 84);36
(define *af:congohigh* 85);37
(define *af:congotap* 86)
(define *af:cowbell* 52)
(define *af:shaker* 68)
(define *af:highgogo* 38)
(define *af:lowgogo* 39)

(*metro* 'set-tempo 95)

(define flute
   (lambda (beat plist plist2 rlist)
    (print (car plist) (car rlist))
    (if (not (= (car plist) -1))
      (begin 
       (play-note (*metro* (+ (car rlist) beat)) ktk (+ (car plist) 1) (if (< (random) .4) 110 80 ) (*metro* 'dur (* .7 (car rlist))) 0)
       (play-note (*metro* (+ (car rlist) beat)) ktk (+ (car plist2) 1) (if (< (random) .4) 110 80 ) (*metro* 'dur (* .7 (car rlist))) 0)
      )
    )
    (callback (*metro* (+ beat (- (car rlist) 0.05))) 'flute (+ beat (car rlist)) (cdr plist)  (cdr plist2) (cdr rlist))
   )
)

(flute (*metro* 'get-beat 2) 
       '(     -1  98  96  94  96  94  91  94  91  89  91  89  86  89  86  84      86  84  82  84  82  79  82  84  79  -1  77     75  81  84  87  86  84  82  81  79  77  82  -1  81  -1  79    77  75  74  82  77  75  74 72 -1     84  82  84  86  84  86  87  86  87  92  87  98   -1   96   -1   94) 
       '(     -1  94  91  89  87  89  86  89  86  84  86  84  82  84  82  81      82  81  79  81  79  74  79  81  74  -1  72     72  77  81  84  82  81  79  77  75  74  79  -1  77  -1  75    74  72  70  79  74  72  71 72 -1     79  77  79  82  79  82  84  82  84  86  84  94   -1   91   -1   89)
       '(.25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25     .25 .25 .25 .25 .25 .25 .75 .25 .25 .25 .25    .25 1/6 1/6 1/6 .25 .25 .25 .25 .25  .5 .25 .25 .25 .25 .25   1/3 1/3 1/3 .25  .5 1/8 1/8  1  3    .25  .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25  .25  .25  .25    2))

       
(define *metre* (make-metre '(4) 1.0))
(define afdrums
   (lambda (beat)
      ;(print beat)
      (for-each
        (lambda (b)
         lambda (play-note (*metro* (+ b beat)) btry *af:snare* 80 (*metro* 'dur 1) 2)                                    
        )
        '( 1 3)
      )
      (for-each
        (lambda (b)
         ; (play-note (*metro* (+ b beat)) btry *af:kick* 115 (*metro* 'dur 1) 2)                                    
        )
        '( 0 .75 1 2 2.75 3)
      )
      (for-each
        (lambda (b)
          (play-note (*metro* (+ b beat)) btry *af:shaker* 80 (*metro* 'dur 1) 2)                                    
        )
        '( 0 .25 .5 .75 1 1.25 1.5 1.75 2 2.25 2.5 2.75 3 3.25 3.5 3.75)
      )
      (for-each
          (lambda (b)
           ; (play-note (*metro* (+ b beat)) btry *af:congohigh* 90 (*metro* 'dur 1) 2)
          )
          '(0 1 2.25 3)
      )
      (for-each
         (lambda (b)
           ;(play-note (*metro* (+ b beat)) btry *af:congolow* 90 (*metro* 'dur 1) 2)
         )
         '( .5 .75 1.75  2.75)
      )
      (for-each
         (lambda (b)
           ;(play-note (*metro* (+ b beat)) btry *af:congotap* 90 (*metro* 'dur 1) 2)
         )
         '( 3.5 3.75)
      )
      (for-each
        (lambda (b)
          ;(play-note (*metro* (+ b beat)) btry *af:highgogo* 90 (*metro* 'dur 1) 2)                                    
        )
        '(0 1 2 3)
      )
      (for-each
        (lambda (b)
         ; (play-note (*metro* (+ b beat)) btry *af:lowgogo* 90 (*metro* 'dur 1) 2)                                    
        )
        '(.5 1.25 1.75 2.5 3.5 3.75)
      )
     (callback (*metro* (+ beat 3.9)) 'afdrums (+ beat 4))
   )
)
(afdrums (*metro* 'get-beat 4.0))

  ;     '( 98  96  94  96  96  91  94  95  91  91  89  86  89  86  84  86  84  82  84  82  79  84  79); -1 77 -1 75 58 84 88 86 84 82 81 79 77 82 -1 81 -1 79 77 76 74 83 77 75 74 72 -1 84 95 84 86 84 86 89 86 89 91 89 98 -1 96 -1 94 )
 ;      '(.25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .75 .25 .25); .25 .75 .25 .25 1/6 1/6 1/6 .25 .25 .25 .25 .25 .5 .25 .25 .25 .25 .25 1/3 1/3 1/3 .25 .5 .125 .125 1 3 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 2)
;)
;dar              '(    -1   98  94  91  94  91  89  94  96  93  91  89  91  89  86  89  91  89  86  84  82  79  82  84  82  79  77 74) 
;dar       '(.25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .5  .25 .25 .25 .25 .25  .25 .5 .25 .25 .25 .25 .5))
       
     ;  '( 84  83  84  86  84  86  88  86  88  92  88  98   -1   96   -1   95)
     ;  '( .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25 .25  .25  .25  .25    2)
     ;  )
       

