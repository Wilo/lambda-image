;;; Generate images with pure functions
;;; Just for fun.
;;; After I started this, I found this:
;;; http://www.frank-buss.de/lisp/texture.html for Common Lisp
;;; which works on the same principle.
;;;
;;; Everything is slow but that's ok because:
;;; 1. This is just an experiment
;;; 2. We can cache the result

(use data-structures chicken-syntax
     mathh ;; for fpmod
     )

(include "lambda-image-util.scm")

;; ***** coloring

(define (rgb r g b)
  (vector r g b))

(define (->rgb c)
  (cond
   ((vector? c) c)
   ((number? c) (rgb c c c))))

(define (R c) (if (vector? c) (vector-ref c 0) c))
(define (G c) (if (vector? c) (vector-ref c 1) c))
(define (B c) (if (vector? c) (vector-ref c 2) c))

(define (make-binary-rgb f)
  (lambda (a b)
    (if (and (number? a) (number? b))
        (f a b)
        (rgb (f (R a) (R b))
             (f (G a) (G b))
             (f (B a) (B b))))))

(define c+2 (make-binary-rgb +))
(define c-2 (make-binary-rgb -))
(define c*2 (make-binary-rgb *))
(define c/2 (make-binary-rgb /))

(define c=2
  (lambda (a b)
    (and (= (R a) (R b))
         (= (G a) (G b))
         (= (B a) (B b)))))


;; TODO make all color-operators support multiple arguments
(define (c+ . lst)
  (foldl (lambda (x s)
          (c+2 x s))
        (rgb 0 0 0)
        lst))

(define (cavg . lst)
  (c/2 (apply c+ lst) (length lst)))


;; ** randomness:
;; we can't use the popular "random" functions, because we want pure
;; functions. hashing (x,y) gives roughly the same effect, but without
;; any side-effect. (random has a side-effect: it changes the internal
;; state of the random-number-generator)
(define hash*
  (foreign-lambda* unsigned-int ((unsigned-int x)) "
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x);
    return(x);"))

;; TODO make this faster
(define (hash x y)
  (/ (fxand #xFF (hash* (fx+ (hash* (fp->fx y))
                           (fp->fx x)))) 255))

(define (hash-color x y)
  (rgb (hash* (fx+ #x77aabb22 (hash x y)))
       (hash* (fx+ #x11bb00ff (hash x y)))
       (hash* (fx+ #x8844ffbb (hash x y)))))


;;; ** interpolation


;; linear interpolation
(define (lerp a b fraction)
  (if (>= fraction 1) (set! fraction 1))
  (if (< fraction 0) (set! fraction 0))
  (c+2 (c*2 b fraction)
       (c*2 a (- 1 fraction))))


;; cosine interpolation
(define (cospol a b x)
  (let* ([xπ (* x π)]
         [f (* 0.5 (+ 1 (cos xπ)))])
    (+ (* f a) (* (- 1 f) b))))


;;; *** misc

;; TODO make a faster version of this if possible
(define fp->fx (o inexact->exact floor))

(define (magnitude x y)
  (sqrt (+ (expt x 2) 
           (expt y 2))))


;; ** image operators


(define (i* proc operand)
  (lambda (x y)
    (c*2 (proc x y) operand)))
  
(define (i+ . procs)
  (lambda (x y)
    (apply c+ (map (lambda (proc) (if (procedure? proc)
                                 (proc x y)
                                 proc))
                   procs))))

;; e.g. (blend (noise) (scale (checkers) 10) cavg)
(define (blend blend-proc . procs)
  (lambda (x y)
    (apply blend-proc (map (lambda (proc) (proc x y)) procs))))

;; blend proc1 and proc2, with a mask (must be greyscale)
(define (mask mask proc1 proc2)
  (lambda (x y)
    (let ([msk (c/2 (mask x y) #xFF)])
      (c+2 (c*2 (proc1 x y) msk)
           (c*2 (proc2 x y) (c-2 1 msk))))))


;; multi-arg version of (cut blend <> <> cavg)
(define (average . procs)
  (apply blend (cons cavg procs)))

(define (imap modifier proc)
  (lambda (x y)
    (modifier (proc x y))))

;; ** lambda-image manipulators

;; proc wil be supplied with decimal coordinates
;; use scale-px to keep integer coordinates
(define (scale proc scale)
  (lambda (x y) (proc (/ x scale)
                 (/ y scale))))

;; scale with pixelation effect
(define (scale-px proc scale)
  (lambda (x y)
    (proc (fx/ x scale) (fx/ y scale))))

;; scale with interpolation. proc gets integer coords.
(define (scale-aa proc scale #!optional (pol cospol))
  (lambda (x y)
    (let* ([x* (fx/ (inexact->exact (floor x)) scale)]
           [y* (fx/ (inexact->exact (floor y)) scale)]
           [dx (/ (fpmod x scale) scale)]
           [dy (/ (fpmod y scale) scale)])
      (pol (pol (proc x*    y*   ) (proc (+ x* 1)    y*  ) dx)
           (pol (proc x* (+ y* 1)) (proc (+ x* 1) (+ y* 1)) dx) dy))))


;; aa with subpixels
(define (antialias proc)
  (lambda (x y)
    (let ([ƒ (lambda (X Y)
               (proc (+ x X) (+ y Y)))])
      (cavg (ƒ -0.25 -0.25)
            (ƒ -0.25 0.25)
            (ƒ 0.25 -0.25)
            (ƒ 0.25 0.25)))))

(define (translate proc X Y)
  (lambda (x y)
    (proc (+ X x) (+ Y y))))

;; repeat pattern width x height. height is optional and defaults to
;; width. widht/height of 0 means don't repeat in that dimension
(define (repeat proc width #!optional (height #f))
  (let ([height (or height width)])
    (let ([px (if (> width 0)
                  (cut fpmod <> width)
                  identity)]
          [py (if (> height 0)
                  (cut fpmod <> height)
                  identity)])
      (lambda (x y)
        (proc (px x) (py y))))))


(define (monochrome proc threshold)
  (lambda (x y)
    (let ([res (proc x y)])
      (if (<= res threshold) 1 0))))

(define (invert proc)
  (lambda (x y)
    (c-2 1 (proc x y))))

;; ** sample images

(define (checkers)
  (lambda (x y)
   (let ([rem-y (modulo (fp->fx y) 2)]
         [rem-x (modulo (fp->fx x) 2)])
     (if (or (= rem-x rem-y)
             (= rem-x rem-y)) 0 1))))

(define (noise)
    (lambda (x y)
      (hash x y)))

(include "opencvt.scm")

(repl)
