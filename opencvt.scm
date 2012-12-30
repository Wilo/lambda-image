

;; Simple Scheme binidng for OpenCV
;; This is quite silly, really. Ended just using it for stroing the
;; image and displaying it. TODO: move over to something more
;; established and simple, like bb.

#>

#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

using namespace std;
using namespace cv;

Mat* create_Mat(int x, int y, unsigned char r, unsigned char g, unsigned char b) {
  Mat *M = new Mat(x, y, CV_8UC3, Scalar(r, g, b));
  //imshow("Display image", *M);
  return M;
}

void print_Mat(Mat* m) {
  cout << "M = " << endl << *m << endl << flush;
}

unsigned int Mat_get(Mat* mat, int x, int y, unsigned char channel) {
  return (*mat).ptr<unsigned char>(x, y) [channel];
}

void Mat_set(Mat* mat, int x, int y, unsigned char channel, unsigned short value) {
  (*mat).ptr<unsigned char>(y, x) [channel] = (unsigned char)value;
}

<#


(define (Mat x y #!optional (r 0) (g 0) (b 0))
  ((foreign-lambda c-pointer "create_Mat" int int   int int int)
   x y r g b))

(define print-Mat (foreign-lambda void "print_Mat" (c-pointer "Mat")))

(define waitKey-c (foreign-lambda int "waitKey" int))

;; swallow all events:
(define (waitKeys)
  (waitKey-c 1)  (waitKey-c 1)  (waitKey-c 1)  (waitKey-c 1)  (waitKey-c 1)
  (let loop ()
    (if (<= (waitKey-c 1) -1)
        (void)
        (loop))))

(define imshow-c (foreign-lambda* void ((c-string winname) ((c-pointer "Mat") mat))
                           "imshow(winname, *mat);"))

;; show image and swallow all events
(define (imshow title mat)
  (imshow-c title mat)
  (waitKeys))


(define (get mat x y)
  (let ([get-c (foreign-lambda unsigned-int "Mat_get"
                          (c-pointer "Mat") int int unsigned-char)])
    (vector (get-c mat x y (integer->char 0))
            (get-c mat x y (integer->char 1))
            (get-c mat x y (integer->char 2)))))

(define set-c (foreign-lambda void "Mat_set"
                         (c-pointer "Mat") int int unsigned-char unsigned-short))


(define (set mat x y color)
  (let ([x (fp->fx x)]
        [y (fp->fx y)]
        [vec (->rgb color)])
    (set-c mat x y (integer->char 0) (fp->fx (vector-ref vec 2)))
    (set-c mat x y (integer->char 1) (fp->fx (vector-ref vec 1)))
    (set-c mat x y (integer->char 2) (fp->fx (vector-ref vec 0)))))


(repl)
