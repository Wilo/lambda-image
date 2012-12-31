(use clojurian-syntax)

(define (image)
  (let* ([spacing 2]
         [radius 7]
         [S 5]
         [circles (lambda ()
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
     (-> (circles) (scale S) (i* (rgb 1 0 0)) (antialias))
     (-> (circles) (scale S) (i* (rgb 0 0 1))))))

(draw (image))

