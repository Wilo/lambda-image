
(begin
  (define width 512)
  (define height 256)

  (define M (Mat height width)))








;; doesn't work. prolly cause it doesn't quietly overflow like C, but
;; produces +inf.0 instead
;; (define (rnd x1)
;;   (let* ([x2 (* (expt (fxshr x1 16) x1) #x45d9f3b)]
;;          [x3 (* (expt (fxshr x2 16) x2) #x45d9f3b)])
;;     (expt (fxshr x3 16) x3)))


;; return 1 or 0 randomly, which % percent chance of 1.
(define (hashfield %)
  (let ([threshold (* #xFF (/ % 100))])
    (lambda (x y)
      ;; everybody loves lexical scoping
      (if (>= threshold (hash x y)) 1 0))))

;; not quite working, need to mix 3 points


;; (mask (lambda (x y) (* 1 (+ 0.5 (* 0.5 (sin (* (magnitude x y) 0.3))))))
      ;;       (lambda (x y) (rgb (c+2 (c*2 (hash x y) 0.25) 50) 50 0))
      ;;       (lambda (x y) (rgb 0 (c+2 (c*2 (hash x y) 0.25) 20) 0)))


(begin
  (define (lonely)
    (lambda (x y) (if (and (= x 0) (= y 0)) 1 0)))


  (time
   (mat-for-each
    (begin
      (mask (average (scale-aa (noise) 64)
                    (scale-aa (noise) 32)
                    ;;(scale-aa (noise) 16)
                    ;;(scale-aa (noise) 8)
                    ;;(scale-aa (noise) 4)
                    (scale-aa (noise) 2)
                    (noise)
                    )
           (i+ (i* (noise) (rgb 0 1 0)) 20)
           (i+ (i* (noise) (rgb 1 0 0)) 20))))
   
   (imshow "hi" M)))


