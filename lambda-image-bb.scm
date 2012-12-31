(use bb lolevel clojurian-syntax)

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
    (let* ([spacing 2]
           [radius 7]
           [S 5]
           [pic (lambda ()
                  (-> (circle radius)
                      (translate (- radius))
                      (repeat (+ spacing (* 2 radius)))))])
      (mask
       (lambda (x y)
         (-> x
             (/ π)
             (/ radius)
             (sin)
             (c+2 1)
             (c*2 0.5)))
       (-> (pic) (scale S)    (i* (rgb 1 0 0)) (antialias))
       (-> (pic) (scale-aa S) (i* (rgb 0 0 1))))))


  (begin
    (gen-image (image) my-setter width height)
    (bb:redraw i)
    (bb:run 0)))
