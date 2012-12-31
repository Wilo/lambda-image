(use imlib2)

(define width 64)
(define height 64)


(define (save img-proc filename #!optional (width 64) (height 64))
  (define I (image-create width height))

  (define (imlib:image-set-pixel! x y c)
    (let ([c->fx (compose inexact->exact floor (lambda (fp) (* 255 fp)) (lambda (channel) (channel c)))])
      (image-draw-pixel I (color/rgba (c->fx R)
                                      (c->fx G)
                                      (c->fx B) 255) x y)))

  (render img-proc imlib:image-set-pixel! width height)
  (image-save I filename))



