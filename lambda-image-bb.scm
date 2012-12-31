(use bb lolevel)

(bb:init)

(begin
  (define width 512)
  (define height 256))

(define w (bb:make-widget 'window 512 256))
(define i (bb:make-widget 'label width height))
(bb:show w)

(set! (bb:property i 'width) width)
(set! (bb:property i 'height) height)

(begin
  ;; (u32vector-length ibuffer)
  (define ibuffer (make-u32vector (* width height) 0 #t #t)))

(begin
  (set! (bb:property i 'image)
        (bb:image (make-locative  ibuffer) width height 4)))


(define (colvec->int v)
  (let ([p (lambda (Q)
             (let ([K (Q v)])
               (if (< K 0) (set! K 0))
               (if (> K 1) (set! K 1))
               (fp->fx (* 255 K))))])
    (+ (fxshl (p R) 0)
       (fxshl (p G) 8)
       (fxshl (p B) 16)
       #xFF000000)))


(define (my-setter x y colvector)
  (u32vector-set! ibuffer (+ x (* y width)) (colvec->int colvector)))

(begin

  (define (image)
    (blend
     c-2
     (i* (repeat (translate (circle 70) -70 -70) 140) (rgb 1 0 1))
     (i* (scale-aa (repeat (translate (circle 7)
                                      -7 -7)
                           14)
                   10) (rgb 0 1 0))))


  (begin
    (gen-image (image) my-setter width height)
    (bb:redraw i)
    (bb:run 0)))
