
(use imlib2)

(define width 512)
(define height 256)

(define I (image-create width height))

(define c (rgb 1.0 0.5 0))

(define (image-set-pixel! x y c)
 (let ([c->fx (compose inexact->exact floor (lambda (fp) (* 255 fp)) (lambda (channel) (channel c)))])
   (image-draw-pixel I (color/rgba (c->fx R)
                                   (c->fx G)
                                   (c->fx B) 255) x y)))



(define FI
  (blend cavg
         (scale-aa (monochrome (noise) 0.5) 10)
         (i* (scale (checkers) 10) (rgb 0.5 0 0))))

(mat-for-each image-set-pixel! FI width height)

(image-save I "/tmp/foo.png")

