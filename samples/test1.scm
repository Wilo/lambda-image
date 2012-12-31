
;; scale-aa looks like a shadow, this is a bug:
;; antialiasing in scale-aa translates image by scale/2
(draw
 (blend cavg
        (scale-aa (monochrome (noise) 0.5) 10)
        (scale    (monochrome (noise) 0.5) 10)))
