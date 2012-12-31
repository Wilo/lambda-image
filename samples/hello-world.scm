;; make canvas bigger:
(resize 200 200)

;; plain red
(draw
 (lambda (x y) (rgb 1 0 0)))

;; random grey noise
(draw (noise))

;; pixelated noise!
(draw (scale (noise) 10))

;; draw a circle @ 0,0
(draw (circle 10))

;; make circle visible
(draw (translate (circle 8) -10))

;; many circles!
(define (circles)
  (repeat (translate (circle 7) -10) 20))

(draw (circles))

;; make them circles prettier
(draw (antialias (circles)))

;; draw red circles
(draw (i* (circles) (rgb 1 0 0)))

;; make some noise
(draw (scale-aa (noise) 10))

;; blend two images together (by averaging colors)
(draw (blend cavg
             (noise) (circles)))

;; look how pretty
(draw (antialias
       (blend cavg
             (i* (circles) (rgb 0 0 1))
             (scale (noise) 20))))

;; save an image section to file
(save (antialias (circles)) "/tmp/circles.png" 100 100)
