(use bb lolevel)

(bb:init)

(begin
  (define width 512)
  (define height 256))

(define *bb-w* (bb:make-widget 'window 512 256))
(define *bb-img* (bb:make-widget 'label width height))
(bb:show *bb-w*)

(define (bb-resize w h)
  (set! width w)
  (set! height h)
  
  (set! (bb:property *bb-img* 'width) width)
  (set! (bb:property *bb-img* 'height) height)

  (set! (bb:property *bb-w* 'width) width)
  (set! (bb:property *bb-w* 'height) height)

  (set! ibuffer (make-u32vector (* width height) 0 #t #t))

  (set! (bb:property *bb-img* 'image)
        (bb:image (make-locative ibuffer) width height 4)))

(bb-resize 100 100)


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

(define (bb-setter x y colvector)
  (u32vector-set! ibuffer (+ x (* y width)) (colvec->int colvector)))

(define (bb-render img-proc)
  (render img-proc bb-setter width height)
  (bb:redraw *bb-img*)
  (let loop ()
    (if (= (bb:run 0))
        (void)
        (loop))))

(define draw bb-render)
(define resize bb-resize)


