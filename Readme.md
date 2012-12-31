
# Lambda Image

Texture generation with a functional perspective. 

Usually, a bitmap image is defined by a finite set of pixels and their colors. These are stored:

```c
// RGBA 2x2 image
// semi-transparent red
float [2][2][4] image =
 { 0,1,0,0.5, 0,1,0,0.5,
   0,1,0,0.5, 0,1,0,0.5, }
```

This experimental piece of software represents images by functions instead. Instead of a stored set of pixels, an image is a function which can calculate the color of the pixels:

```scheme
;; semi-transparent red
(lambda (x y) (rgba 0 1 0 0.5))
```

These functions are boundless and are easy to combine to make patterns and simple effects.

## Samples

```scheme
;; make canvas bigger:
(resize 200 200)
```

```scheme
;; plain red
(draw
 (lambda (x y) (rgb 1 0 0)))
```

```scheme
;; random grey noise
(draw (noise))
```

```scheme
;; pixelated noise!
(draw (scale (noise) 10))
```

```scheme
;; draw a circle @ 0,0
(draw (circle 10))
```

```scheme
;; make circle visible
(draw (translate (circle 8) -10))
```

```scheme
;; many circles!
(define (circles)
  (repeat (translate (circle 7) -10) 20))
(draw (circles))
```

```scheme
;; make them circles prettier
(draw (antialias (circles)))
```

```scheme
;; draw red circles
(draw (i* (circles) (rgb 1 0 0)))
```

```scheme
;; make some noise
(draw (scale-aa (noise) 10))
```

```scheme
;; blend two images together (by averaging colors)
(draw (blend cavg
             (noise) (circles)))
```

```scheme
;; look how pretty
(draw (antialias
       (blend cavg
             (i* (circles) (rgb 0 0 1))
             (scale (noise) 20))))
```

```scheme
;; save an image section to file
(save (antialias (circles)) "/tmp/circles.png" 100 100)
```

## Installing

```shell
$ git clone https://github.com/kristianlm/lambda-image.git
$ cd lambda-image
# with [Chicken scheme](http://call-cc.org) installed, run
$ csc lambda-image.scm -c++
$ # you can optimize with this if you want: -local -inline -inline-global -optimize-leaf-routines -u
$ ./lambda-image
#;> (draw (noise))
```
